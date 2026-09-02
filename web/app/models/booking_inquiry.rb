class BookingInquiry < ApplicationRecord
  belongs_to :availability_block, optional: true

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :guest_name, with: ->(name) { name.strip }

  validates :check_in, :check_out, :guest_name, :email, :locale, :status, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :adults, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :children, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :locale, inclusion: { in: %w[en fr] }
  validates :status, inclusion: { in: %w[new contacted accepted declined cancelled] }
  validate :ends_after_start
  validate :stay_rules_allow_requested_stay

  def nights
    return 0 if check_in.blank? || check_out.blank?

    (check_out - check_in).to_i
  end

  private

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
