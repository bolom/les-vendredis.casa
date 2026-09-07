require "uri"

module MachineBookings
  class PaymentConfiguration
    class Invalid < StandardError; end

    def self.fetch(key)
      AppConfig.fetch("X402_#{key.to_s.upcase}", :x402, key)
    end

    def self.validate!
      raise Invalid unless fetch(:enabled).to_s == "true"
      [ fetch(:pay_to), fetch(:asset) ].each do |address|
        raise Invalid unless address.to_s.match?(/\A0x[0-9a-fA-F]{40}\z/) && address.to_s !~ /\A0x0{40}\z/
      end
      raise Invalid unless fetch(:chain_id).to_s.match?(/\A[1-9][0-9]{0,9}\z/)
      raise Invalid unless fetch(:decimals).to_s.match?(/\A(?:[0-9]|1[0-8])\z/)
      raise Invalid unless fetch(:token_name).is_a?(String) && fetch(:token_name).present?
      raise Invalid unless fetch(:token_version).is_a?(String) && fetch(:token_version).present?
      # The catalogue is priced in euros. No implicit USD conversion is permitted.
      raise Invalid unless Quote.currency == "EURC"
      uri = URI.parse(fetch(:facilitator_url).to_s)
      raise Invalid unless uri.is_a?(URI::HTTPS) && uri.host.present? && uri.userinfo.nil? && uri.query.nil? && uri.fragment.nil?
      Quote.unit_price
      true
    rescue URI::InvalidURIError, ArgumentError
      raise Invalid
    end

    def self.configured?
      validate!
    rescue Invalid
      false
    end

    def self.requirements(quote)
      validate!
      amount = quote.total_price * (10 ** fetch(:decimals).to_i)
      raise Invalid unless amount == amount.to_i && amount.positive?

      { scheme: "exact", network: "eip155:#{fetch(:chain_id)}", amount: amount.to_i.to_s,
        asset: fetch(:asset), payTo: fetch(:pay_to), maxTimeoutSeconds: 900,
        extra: { name: fetch(:token_name), version: fetch(:token_version) } }.deep_stringify_keys
    end
  end
end
