# Shared payment-instruction data for the confirmation page and the
# guest_acceptance email (issue #92). One source of truth for both surfaces.
module PaymentInstructionsHelper
  # Bank coordinates come from credentials as separate fields
  # (payment: { iban, beneficiary, bic, wallet }). Rendered as a single block;
  # nothing renders when none is set.
  def payment_bank_details
    details = Rails.application.credentials[:payment]
    return if details.blank?

    lines = []
    lines << (fr_locale? ? "Bénéficiaire : #{details[:beneficiary]}" : "Beneficiary: #{details[:beneficiary]}") if details[:beneficiary].present?
    lines << (fr_locale? ? "IBAN : #{details[:iban]}" : "IBAN: #{details[:iban]}") if details[:iban].present?
    lines << (fr_locale? ? "BIC : #{details[:bic]}" : "BIC: #{details[:bic]}") if details[:bic].present?
    lines << (fr_locale? ? "Portefeuille : #{details[:wallet]}" : "Wallet: #{details[:wallet]}") if details[:wallet].present?
    lines.join("\n").presence
  end

  # True if the current booking inquiry is for a French guest.
  def fr_locale?
    @booking_inquiry&.locale.to_s == "fr"
  end

  # Payment deadline in days, overridable via AppConfig (default: 7).
  def payment_deadline_days
    raw = AppConfig.fetch(
      "PAYMENT_DEADLINE_DAYS",
      :payment, :deadline_days,
      default: 7
    )
    Integer(raw)
  rescue ArgumentError, TypeError
    7
  end

  # The date by which payment should be received.
  def payment_due_date
    @booking_inquiry.accepted_at.to_date + payment_deadline_days
  end

  # Formatted due date, locale-aware (the inquiry carries its own locale).
  def payment_due_date_l
    I18n.with_locale(@booking_inquiry.locale) do
      l(payment_due_date, format: "%-d %B %Y")
    end
  end

  def payment_amount_eur
    @booking_inquiry.accepted_total_price_eur
  end

  def payment_nightly_price_eur
    @booking_inquiry.accepted_nightly_price_eur
  end
end
