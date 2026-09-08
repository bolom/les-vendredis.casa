class AvailabilityBlock < ApplicationRecord
  BLOCKING_STATUSES = %w[tentative confirmed].freeze

  has_many :booking_inquiries, dependent: :nullify

  validates :starts_on, :ends_on, :kind, :source, :status, presence: true
  validates :kind, inclusion: { in: %w[manual_closure direct_stay] }
  validates :source, inclusion: { in: %w[direct manual] }
  validates :status, inclusion: { in: %w[tentative confirmed cancelled] }
  validate :ends_after_start
  validate :blocking_range_does_not_overlap
  before_update :protect_linked_booking_dates
  before_update :protect_unresolved_payment
  before_update :protect_managed_stay
  after_update :cancel_linked_bookings

  scope :blocking, -> { where(status: BLOCKING_STATUSES) }
  scope :overlapping, ->(starts_on, ends_on) { where("starts_on < ? AND ends_on > ?", ends_on, starts_on) }

  # Set by the booking business paths (PaymentOrder#reconcile!) so a managed
  # stay's status can only be changed through reconciliation, never by the
  # generic admin form or an arbitrary update.
  attr_accessor :business_transition

  def blocking?
    status.in?(BLOCKING_STATUSES)
  end

  def direct_stay?
    kind == "direct_stay"
  end

  def managed_by_payment?
    PaymentOrder.where(availability_block_id: id, status: %w[settling review paid]).exists?
  end

  private

  def protect_unresolved_payment
    return unless status_changed?
    return if business_transition
    return unless managed_by_payment?

    errors.add(:base, "Reconcile the payment before changing this block's status")
    throw :abort
  end

  def protect_managed_stay
    return unless direct_stay?
    return if business_transition && !dates_changed?

    if status_changed? && status != "cancelled"
      errors.add(:base, "This stay's status is managed by its booking; use the booking actions")
      throw :abort
    end
    return unless dates_changed?

    errors.add(:base, "This stay's dates are managed by its booking")
    throw :abort
  end

  def dates_changed?
    starts_on_changed? || ends_on_changed?
  end

  def protect_linked_booking_dates
    return unless (starts_on_changed? || ends_on_changed?) && booking_inquiries.exists?

    errors.add(:base, "Cancel the booking before changing its dates")
    throw :abort
  end

  def cancel_linked_bookings
    return unless saved_change_to_status? && status == "cancelled"

    booking_inquiries.where(status: "accepted").find_each { |inquiry| inquiry.update!(status: "cancelled") }
  end

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
