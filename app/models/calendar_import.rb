class CalendarImport < ApplicationRecord
  PROVIDERS = %w[airbnb booking].freeze

  has_many :calendar_events, dependent: :destroy

  validates :provider, presence: true, uniqueness: true, inclusion: { in: PROVIDERS }
  validates :last_status, inclusion: { in: %w[never_synced success failed] }
  validates :last_duration_ms, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :last_event_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  def self.ensure_defaults!
    PROVIDERS.each { |provider| find_or_create_by!(provider: provider) }
  end

  def stale?
    last_synced_at.blank? || last_synced_at < 30.minutes.ago
  end
end
