require "digest"
require "base64"

module MachineBookings
  class Checkout
    class Invalid < StandardError; end
    class Conflict < StandardError; end
    class Pending < StandardError; end

    def initialize(order, facilitator: Facilitator.new)
      @order, @facilitator = order, facilitator
    end

    def call(encoded, guest)
      payload = decode(encoded)
      key = authorization_key(payload)
      @order.with_lock do
        raise Conflict if @order.authorization_key.present? && @order.authorization_key != key
        return @order if @order.status == "paid"
        raise Pending if %w[settling review].include?(@order.status)
        raise Conflict unless @order.status == "quoted"
        raise Invalid if @order.expires_at <= Time.current
        validate_authorization!(payload)
        verification = @facilitator.call("verify", payload, @order.requirements)
        raise Invalid unless verification["isValid"] == true
        reserve!(key, guest)
      end

      # The hold and authorization identity are committed BEFORE any external settlement.
      # An interrupted/ambiguous settlement is never retried automatically.
      begin
        result = @facilitator.call("settle", payload, @order.requirements)
        @order.update!(settlement: result)
        @order.with_lock do
          unless result["success"] == true && result["network"] == @order.requirements["network"] && result["transaction"].to_s.match?(/\A0x[0-9a-fA-F]{64}\z/)
            @order.update!(status: "review")
            return @order
          end
          if CalendarEvent.blocking.overlapping(@order.availability_block.starts_on, @order.availability_block.ends_on).exists?
            @order.update!(status: "review")
            return @order
          end
          @order.availability_block.update!(status: "confirmed", business_transition: true)
          @order.booking_inquiry.update!(status: "accepted", accepted_at: Time.current)
          @order.update!(status: "paid")
        end
      rescue StandardError
        @order.update!(status: "review")
        raise Pending
      end
      @order
    rescue ActiveRecord::RecordNotUnique
      raise Conflict
    rescue ActiveRecord::StatementInvalid => error
      raise unless error.cause.is_a?(PG::ExclusionViolation)
      raise Conflict
    end

    private

    def decode(encoded)
      raise Invalid unless encoded.is_a?(String) && encoded.bytesize <= 16_384
      value = JSON.parse(Base64.strict_decode64(encoded))
      raise Invalid unless value.is_a?(Hash) && value["x402Version"] == 2 && value["accepted"] == @order.requirements
      raise Invalid unless value.dig("payload", "authorization").is_a?(Hash)
      value
    rescue JSON::ParserError, ArgumentError, TypeError
      raise Invalid
    end

    def authorization_key(payload)
      auth = payload.fetch("payload").fetch("authorization")
      raise Invalid unless auth["from"].to_s.match?(/\A0x[0-9a-fA-F]{40}\z/) && auth["nonce"].to_s.match?(/\A0x[0-9a-fA-F]{64}\z/)
      raise Invalid unless auth["nonce"].downcase == "0x#{Digest::SHA256.hexdigest(@order.public_id)}"
      Digest::SHA256.hexdigest([ @order.requirements["network"], @order.requirements["asset"].downcase, auth["from"].downcase, auth["nonce"].downcase, payload.dig("payload", "signature") ].join(":"))
    end

    def validate_authorization!(payload)
      auth = payload.fetch("payload").fetch("authorization")
      raise Invalid unless auth["to"].to_s.downcase == @order.requirements["payTo"].downcase && auth["value"] == @order.requirements["amount"]
      raise Invalid unless %w[validAfter validBefore].all? { |key| auth[key].is_a?(String) && auth[key].match?(/\A[0-9]{1,12}\z/) }
      raise Invalid unless auth["validAfter"].to_i <= Time.current.to_i && auth["validBefore"].to_i > Time.current.to_i && auth["validBefore"].to_i <= @order.expires_at.to_i
      raise Invalid unless payload.dig("payload", "signature").to_s.match?(/\A0x[0-9a-fA-F]{130}\z/)
    end

    def reserve!(key, guest)
      quote = @order.quote
      check = Availability::Check.new(from: quote["date"], to: quote["checkOut"])
      raise Conflict unless check.available?(check_in: quote["date"], check_out: quote["checkOut"])
      inquiry = BookingInquiry.new(guest.merge(check_in: quote["date"], check_out: quote["checkOut"], adults: quote["adults"], children: quote["children"]))
      inquiry.contact_consent ||= "0"
      inquiry.consent_at = Time.current if inquiry.contact_consent == "1"
      inquiry.save!(context: :public_submission)
      block = AvailabilityBlock.create!(starts_on: inquiry.check_in, ends_on: inquiry.check_out, kind: "direct_stay", source: "direct", status: "tentative")
      inquiry.update!(availability_block: block)
      @order.update!(authorization_key: key, status: "settling", booking_inquiry: inquiry, availability_block: block)
    end
  end
end
