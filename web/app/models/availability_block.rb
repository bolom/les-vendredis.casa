class AvailabilityBlock < ApplicationRecord
  BLOCKING_STATUSES = %w[tentative confirmed].freeze

  has_many :booking_inquiries, dependent: :nullify

  validates :starts_on, :ends_on, :kind, :source, :status, presence: true
  validates :kind, inclusion: { in: %w[manual_closure direct_stay] }
  validates :source, inclusion: { in: %w[direct manual] }
  validates :status, inclusion: { in: %w[tentative confirmed cancelled] }
  validate :ends_after_start
  validate :blocking_range_does_not_overlap

  scope :blocking, -> { where(status: BLOCKING_STATUSES) }
  scope :overlapping, ->(starts_on, ends_on) { where("starts_on < ? AND ends_on > ?", ends_on, starts_on) }

  def blocking?
    status.in?(BLOCKING_STATUSES)
  end

  private

  def ends_after_start
    return if starts_on.blank? || ends_on.blank?

    errors.add(:ends_on, "must be after starts_on") unless ends_on > starts_on
  end

  def blocking_range_does_not_overlap
    return unless blocking?
    return if starts_on.blank? || ends_on.blank? || ends_on <= starts_on

    overlapping_block = self.class.blocking.overlapping(starts_on, ends_on)
    overlapping_block = overlapping_block.where.not(id: id) if persisted?

    errors.add(:base, "availability block overlaps an existing blocking stay") if overlapping_block.exists?
  end
end
