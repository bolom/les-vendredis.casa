class CalendarEvent < ApplicationRecord
  belongs_to :calendar_import

  validates :external_uid, :starts_on, :ends_on, :status, :fingerprint, presence: true
  validates :external_uid, uniqueness: { scope: :calendar_import_id }
  validates :status, inclusion: { in: %w[confirmed cancelled] }
  validate :ends_after_start

  scope :blocking, -> { joins(:calendar_import).where(status: "confirmed", calendar_imports: { active: true }) }
  scope :overlapping, ->(starts_on, ends_on) { where("calendar_events.starts_on < ? AND calendar_events.ends_on > ?", ends_on, starts_on) }

  private

  def ends_after_start
    return if starts_on.blank? || ends_on.blank?

    errors.add(:ends_on, "must be after starts_on") unless ends_on > starts_on
  end
end
