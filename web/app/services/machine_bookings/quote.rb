require "bigdecimal"
require "base64"
require "json"

module MachineBookings
  class Quote
    class InvalidPrice < ArgumentError; end
    DEFAULT_UNIT_PRICE_EUR = "74".freeze
    DEFAULT_NETWORK = "polygon".freeze
    DEFAULT_CHAIN_ID = 137
    DEFAULT_ASSET = "EURC".freeze
    DEFAULT_EXPIRY = 15.minutes

    attr_reader :check_in, :check_out, :nights, :guests, :adults, :children, :errors, :expires_at

    def self.build(params)
      new(
        date: params[:date].presence || params[:checkIn].presence || params[:check_in],
        nights: params[:nights],
        guests: params[:guests], adults: params[:adults], children: params[:children]
      ).tap(&:validate)
    end

    def self.unit_price
      value = BigDecimal((StayRule.current.nightly_price_eur || AppConfig.fetch("MACHINE_BOOKING_PRICE_EUR", :booking, :machine_price_eur, default: DEFAULT_UNIT_PRICE_EUR)).to_s)
      raise InvalidPrice, "Invalid nightly price" unless value.finite? && value.positive? && value <= 100_000 && value.round(2) == value
      value
    rescue ArgumentError
      raise InvalidPrice, "Invalid nightly price"
    end

    def self.currency
      AppConfig.fetch("MACHINE_BOOKING_CURRENCY", :booking, :machine_currency, default: DEFAULT_ASSET)
    end

    def self.network
      PaymentConfiguration.fetch(:chain_id).present? ? "eip155:#{chain_id}" : DEFAULT_NETWORK
    end

    def self.chain_id
      AppConfig.fetch("X402_CHAIN_ID", :x402, :chain_id, default: DEFAULT_CHAIN_ID).to_i
    end

    def self.asset
      AppConfig.fetch("X402_ASSET", :x402, :asset, default: currency)
    end

    def self.pay_to
      AppConfig.fetch("X402_PAY_TO", :x402, :pay_to)
    end

    def self.payment_configured?
      PaymentConfiguration.configured?
    end

    def initialize(date:, nights:, guests: nil, adults: nil, children: nil)
      @raw_date = date
      @nights = coerce_integer(nights)
      @adults = coerce_integer(adults.nil? ? guests : adults)
      @children = coerce_integer(children.nil? ? 0 : children, minimum: 0)
      @guests = @adults + @children if @adults && @children
      @errors = []
      @expires_at = DEFAULT_EXPIRY.from_now.utc
    end

    def validate
      @check_in = coerce_date(@raw_date)
      errors << "date must be an ISO date" if check_in.blank?
      errors << "nights must be a positive integer" if nights.blank? || nights < 1
      errors << "guests must be a positive integer" if guests.blank? || guests < 1
      return self if errors.any?

      @check_out = check_in + nights.days
      validate_stay_rules
      validate_availability
      self
    end

    def valid?
      errors.empty?
    end

    def unit_price
      self.class.unit_price
    end

    def total_price
      unit_price * nights
    end

    def payment_configured?
      self.class.payment_configured?
    end

    def as_json(*)
      {
        date: check_in.iso8601,
        checkOut: check_out.iso8601,
        nights: nights,
        guests: guests,
        adults: adults,
        children: children,
        unitPrice: decimal_string(unit_price),
        totalPrice: decimal_string(total_price),
        currency: self.class.currency,
        network: self.class.network,
        chainId: self.class.chain_id,
        asset: self.class.asset,
        payTo: self.class.pay_to,
        paymentConfigured: payment_configured?,
        expiresAt: expires_at.iso8601
      }
    end

    private

    def validate_stay_rules
      rule = StayRule.current
      stay = Struct.new(:check_in, :check_out, :adults, :children).new(check_in, check_out, adults, children)

      rule.validate_stay(stay).each do |attribute, message|
        errors << "#{attribute} #{message}"
      end
    end

    def validate_availability
      return if Availability::Check.new(from: check_in, to: check_out).available?(check_in: check_in, check_out: check_out)

      errors << "dates are not available"
    end

    def coerce_date(value)
      Date.iso8601(value.to_s)
    rescue ArgumentError, TypeError
      nil
    end

    def coerce_integer(value, minimum: 1)
      return nil unless value.is_a?(Integer) || (value.is_a?(String) && value.match?(/\A[0-9]{1,3}\z/))
      return nil unless value.to_i.between?(minimum, 365)

      Integer(value)
    rescue ArgumentError, TypeError
      nil
    end

    def decimal_string(value)
      value.to_s("F").sub(/\.0+\z/, "")
    end
  end
end
