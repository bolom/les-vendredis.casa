module ApplicationHelper
  # Shared with the public content_pages controller: the admin preview must
  # render exactly what the public site will render for the same body_html.
  def sanitized_content_body_html(content_page)
    sanitize(
      content_page.body_html,
      tags: Rails::HTML5::SafeListSanitizer.allowed_tags + %w[section picture source figure figcaption time],
      attributes: Rails::HTML5::SafeListSanitizer.allowed_attributes + %w[
        class id src srcset sizes alt loading width height fetchpriority datetime
        data-availability-url data-email-link data-email-text data-ep-u data-ep-d
        data-lv-action data-lv-index
      ]
    )
  end

  # ── Admin human language helpers ──────────────────────────────────────────
  # The back-office speaks French to its operators: "12 octobre", never
  # "2026-10-12"; "il y a 4 min", never raw timestamps.

  def human_date(date)
    return "—" if date.blank?

    l(date.to_date, format: "%-d %B")
  end

  def human_date_range(from_date, to_date)
    return "—" if from_date.blank? || to_date.blank?

    from = from_date.to_date
    to = to_date.to_date
    if from.year == to.year && from.month == to.month
      "#{from.day} → #{human_date(to)}"
    elsif from.year == to.year
      "#{human_date(from)} → #{human_date(to)}"
    else
      "#{l(from, format: "%-d %B %Y")} → #{l(to, format: "%-d %B %Y")}"
    end
  end

  def human_ago(time)
    return "à l’instant" if time.blank?

    seconds = Time.current - time
    return "à l’instant" if seconds < 60

    minutes = (seconds / 60).round
    return "il y a #{minutes} min" if minutes < 60

    hours = (seconds / 1.hour).round
    return "il y a #{hours} h" if hours < 24

    days = (seconds / 1.day).round
    "il y a #{days} j"
  end

  def human_nights(from_date, to_date)
    nights = (to_date.to_date - from_date.to_date).to_i
    "#{nights} nuit#{'s' if nights > 1}"
  end

  # Who occupies a blocking stay, in human language: the guest name when the
  # direct stay has an inquiry, the label otherwise.
  def stay_occupant(stay)
    if stay.direct_stay?
      stay.booking_inquiries.order(:created_at).last&.guest_name || stay.summary.presence || "Séjour direct"
    else
      stay.summary.presence || "Blocage maison"
    end
  end

  def euros(amount)
    return nil if amount.blank?

    "#{number_with_delimiter(amount.round, delimiter: " ")} €"
  end

  PAYMENT_STATUS_LABELS = {
    "quoted" => "Devis émis",
    "settling" => "Règlement en cours",
    "paid" => "Payé",
    "review" => "À vérifier",
    "refunded" => "Remboursé",
    "cancelled" => "Annulé"
  }.freeze

  def human_payment_status(status)
    PAYMENT_STATUS_LABELS.fetch(status, status)
  end

  def human_platform(provider)
    t("admin.calendar_imports.platforms.#{provider}", default: provider)
  end

  INQUIRY_STATUS_LABELS = {
    "new" => "À traiter",
    "contacted" => "En discussion",
    "accepted" => "Acceptée",
    "declined" => "Refusée",
    "cancelled" => "Annulée"
  }.freeze

  def human_inquiry_status(status)
    INQUIRY_STATUS_LABELS.fetch(status, status)
  end

  # Colour tone of an inquiry state badge: pending work stands out, terminal
  # states stay neutral. The label itself always carries the meaning.
  def inquiry_state_tone(status)
    case status
    when "new", "contacted" then :pending
    when "accepted" then :ok
    else :neutral
    end
  end

  # Simple two-state summary for the day-to-day screen: "À jour" when the last
  # sync succeeded recently, "Problème" otherwise. Details live in the
  # technical diagnostics screen only.
  def calendar_sync_summary(calendar_import)
    if calendar_import.last_status == "success" && calendar_import.last_synced_at.present? && calendar_import.last_synced_at > 24.hours.ago
      { state: :ok, label: "À jour · synchronisé #{human_ago(calendar_import.last_synced_at)}" }
    elsif calendar_import.last_status == "failed"
      { state: :problem, label: "Problème · dernière synchronisation échouée" }
    elsif calendar_import.last_synced_at.present?
      { state: :problem, label: "Problème · pas synchronisé depuis #{human_ago(calendar_import.last_synced_at)}" }
    else
      { state: :problem, label: "Problème · jamais synchronisé" }
    end
  end
end
