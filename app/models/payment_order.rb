class PaymentOrder < ApplicationRecord
  belongs_to :booking_inquiry, optional: true
  belongs_to :availability_block, optional: true
  before_validation { self.public_id ||= SecureRandom.uuid }
  validates :public_id, :quote, :requirements, :expires_at, presence: true
  attr_readonly :public_id, :quote, :requirements, :expires_at

  def reconcile!(outcome:, evidence:, actor:)
    raise ArgumentError unless %w[confirmed refunded no_transfer].include?(outcome)
    raise ArgumentError unless evidence.is_a?(String) && evidence.strip.length.between?(20, 2000) && actor
    with_lock do
      raise ArgumentError unless %w[settling review paid].include?(status) && availability_block && booking_inquiry
      raise ArgumentError if status == "settling" && updated_at > 5.minutes.ago
      if outcome == "confirmed"
        raise ArgumentError if CalendarEvent.blocking.overlapping(availability_block.starts_on, availability_block.ends_on).exists?
        availability_block.update!(status: "confirmed", business_transition: true)
        booking_inquiry.update!(
          status: "accepted",
          accepted_at: booking_inquiry.accepted_at || Time.current,
          accepted_nightly_price_eur: quote["unitPrice"],
          accepted_total_price_eur: quote["totalPrice"]
        )
        update!(status: "paid")
      else
        raise ArgumentError if outcome == "no_transfer" && (status == "paid" || settlement&.dig("success") == true)
        update!(status: outcome == "refunded" ? "refunded" : "cancelled")
        availability_block.update!(status: "cancelled", business_transition: true)
        booking_inquiry.update!(status: "cancelled") unless booking_inquiry.reload.status_cancelled?
      end
      update!(reconciliation: { outcome: outcome, evidence: evidence, actor_id: actor.id, at: Time.current.iso8601 })
    end
  end

  ALLOWED_CHALLENGE_HOSTS = [ "lesvendredis.casa" ].freeze

  def challenge
    { x402Version: 2, resource: { url: resource_url, mimeType: "application/json" }, accepts: [ requirements ] }
  end

  private

  # The challenge describes the resource to pay for. Its host comes from explicit
  # configuration (APP_HOST / credentials app.host, same source as production
  # mailer URLs), never from request headers, and is strictly allowlisted so an
  # unexpected value fails closed instead of advertising a forged resource.
  def resource_url
    host = AppConfig.fetch("APP_HOST", :app, :host, default: "lesvendredis.casa")
    unless ALLOWED_CHALLENGE_HOSTS.include?(host)
      raise KeyError, "Refusing to build x402 challenge with unauthorized APP_HOST: #{host.inspect}"
    end
    "https://#{host}/book?quote_id=#{public_id}"
  end
end
