class CalendarImport < ApplicationRecord
  PROVIDERS = %w[airbnb booking].freeze
  DEFAULT_FRESHNESS_THRESHOLDS = {
    "airbnb" => 4.hours,
    "booking" => 4.hours
  }.freeze

  has_many :calendar_events, dependent: :destroy

  validates :provider, presence: true, uniqueness: true, inclusion: { in: PROVIDERS }
  validates :last_status, inclusion: { in: %w[never_synced success failed] }
  validates :last_duration_ms, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :last_event_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  def self.ensure_defaults!
    PROVIDERS.each { |provider| find_or_create_by!(provider: provider) }
  end

  def stale?
    last_synced_at.blank? || last_synced_at < freshness_threshold.ago
  end

  def freshness_threshold
    configured_minutes = AppConfig.fetch(
      "#{provider.upcase}_ICAL_STALE_AFTER_MINUTES",
      :calendars,
      :"#{provider}_stale_after_minutes",
      default: DEFAULT_FRESHNESS_THRESHOLDS.fetch(provider).in_minutes.to_i
    )

    Integer(configured_minutes).minutes
  rescue ArgumentError, TypeError
    raise ArgumentError, "Invalid iCal freshness threshold for #{provider}: #{configured_minutes.inspect}"
  end

  def freshness_threshold_description
    minutes = freshness_threshold.in_minutes.to_i
    return "#{minutes / 60} hours" if (minutes % 60).zero?

    "#{minutes} minutes"
  end
end
