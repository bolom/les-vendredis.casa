require "bigdecimal"
require "base64"
require "json"

module MachineBookings
  class Quote
    DEFAULT_UNIT_PRICE_EUR = "74".freeze
    DEFAULT_NETWORK = "polygon".freeze
    DEFAULT_CHAIN_ID = 137
    DEFAULT_ASSET = "EURC".freeze
    DEFAULT_EXPIRY = 15.minutes

    attr_reader :check_in, :check_out, :nights, :guests, :errors, :expires_at

    def self.build(params)
      new(
        date: params[:date].presence || params[:checkIn].presence || params[:check_in],
        nights: params[:nights],
        guests: params[:guests]
      ).tap(&:validate)
    end

    def self.unit_price
      BigDecimal(AppConfig.fetch("MACHINE_BOOKING_PRICE_EUR", :booking, :machine_price_eur, default: DEFAULT_UNIT_PRICE_EUR).to_s)
    end

    def self.currency
      AppConfig.fetch("MACHINE_BOOKING_CURRENCY", :booking, :machine_currency, default: DEFAULT_ASSET)
    end

    def self.network
      AppConfig.fetch("X402_NETWORK", :x402, :network, default: DEFAULT_NETWORK)
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

    def initialize(date:, nights:, guests:)
      @raw_date = date
      @nights = coerce_integer(nights)
      @guests = coerce_integer(guests)
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
      self.class.pay_to.present?
    end

    def amount_base_units
      (total_price * 1_000_000).to_i.to_s
    end

    def as_json(*)
      {
        date: check_in.iso8601,
        checkOut: check_out.iso8601,
        nights: nights,
        guests: guests,
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

    def payment_method
      {
        scheme: "x402",
        network: self.class.network,
        chainId: self.class.chain_id,
        asset: self.class.asset,
        recipient: self.class.pay_to,
        amount: amount_base_units,
        decimals: 6,
        currency: self.class.currency,
        expiresAt: expires_at.iso8601
      }
    end

    def authenticate_header
      payload = {
        amount: amount_base_units,
        asset: self.class.asset,
        currency: self.class.currency,
        recipient: self.class.pay_to,
        network: self.class.network,
        chainId: self.class.chain_id,
        expiresAt: expires_at.iso8601
      }

      %(Payment request="#{Base64.strict_encode64(JSON.generate(payload))}")
    end

    private

    def validate_stay_rules
      rule = StayRule.current
      adults = [ guests, rule.maximum_adults ].min
      children = guests - adults
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

    def coerce_integer(value)
      Integer(value)
    rescue ArgumentError, TypeError
      nil
    end

    def decimal_string(value)
      value.to_s("F").sub(/\.0+\z/, "")
    end
  end
end
