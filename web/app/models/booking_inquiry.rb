require "securerandom"

class BookingInquiry < ApplicationRecord
  belongs_to :availability_block, optional: true

  before_validation :assign_public_reference, on: :create

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

  def nights
    return 0 if check_in.blank? || check_out.blank?

    (check_out - check_in).to_i
  end

  def accept!
    with_lock do
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
    update!(status: "declined", declined_at: Time.current)
  end

  private

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
