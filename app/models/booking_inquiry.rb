require "securerandom"

class BookingInquiry < ApplicationRecord
  belongs_to :availability_block, optional: true

  before_validation :assign_public_reference, if: :new_record?
  after_create :record_submission_notifications
  after_update :record_status_notification

  enum :status, {
    new: "new",
    contacted: "contacted",
    accepted: "accepted",
    declined: "declined",
    cancelled: "cancelled"
  }, prefix: true, validate: true

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :guest_name, with: ->(name) { name.strip }

  validates :check_in, :check_out, :guest_name, :email, :locale, :public_reference, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :adults, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :children, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :locale, inclusion: { in: %w[en fr] }
  validate :ends_after_start
  validate :stay_rules_allow_requested_stay
  validate :future_arrival, if: :new_record?
  attr_accessor :contact_consent
  # Set when an already-agreed stay is recorded on the guest's behalf: the
  # owner must know, but the guest must not receive a "we received your
  # request" email for a booking they did not submit.
  attr_accessor :skip_guest_acknowledgement
  validates :contact_consent, acceptance: true, on: :public_submission

  def nights
    return 0 if check_in.blank? || check_out.blank?

    (check_out - check_in).to_i
  end

  def accept!
    with_lock do
      return false if status_accepted?
      raise ActiveRecord::RecordInvalid, self unless status_new? || status_contacted?
      raise ActiveRecord::RecordInvalid, self unless Availability::Check.new(from: check_in, to: check_out).available?(check_in: check_in, check_out: check_out)

      block = AvailabilityBlock.create!(
        starts_on: check_in,
        ends_on: check_out,
        kind: "direct_stay",
        source: "direct",
        status: "confirmed",
        summary: "Direct booking inquiry #{public_reference}"
      )
      update!(status: "accepted", accepted_at: Time.current, availability_block: block)
    end
  end

  def decline!
    with_lock do
      return false if status_declined?
      raise ActiveRecord::RecordInvalid, self unless (status_new? || status_contacted?) && availability_block_id.nil?

      update!(status: "declined", declined_at: Time.current)
    end
  end

  # Cancels an accepted stay by cancelling the house block that holds its
  # dates: the block callbacks cascade (inquiry cancelled, guest notified,
  # dates freed). Payment-protected blocks refuse to change, so callers get a
  # symbolic result to translate instead of a raw Rails error.
  def cancel_stay!
    with_lock do
      return :already if status_cancelled?
      return :no_stay unless status_accepted? && availability_block.present?

      availability_block.status = "cancelled"
      return :ok if availability_block.save

      availability_block.managed_by_payment? ? :payment_pending : :invalid
    end
  end

  private

  def record_submission_notifications
    BookingNotification.record!(self, "owner_notification")
    BookingNotification.record!(self, "guest_acknowledgement") unless skip_guest_acknowledgement
  end

  def record_status_notification
    return unless saved_change_to_status?
    event = { "accepted" => "guest_acceptance", "declined" => "guest_decline", "cancelled" => "guest_cancellation" }[status]
    BookingNotification.record!(self, event) if event
  end

  def future_arrival
    errors.add(:check_in, "must not be in the past") if check_in.present? && check_in < Date.current
  end

  def assign_public_reference
    self.public_reference ||= "LV-#{SecureRandom.alphanumeric(8).upcase}"
  end

  def ends_after_start
    return if check_in.blank? || check_out.blank?

    errors.add(:check_out, "must be after check_in") unless check_out > check_in
  end

  def stay_rules_allow_requested_stay
    return if check_in.blank? || check_out.blank? || check_out <= check_in

    StayRule.current.validate_stay(self).each do |attribute, message|
      errors.add(attribute, message)
    end
  end
end
