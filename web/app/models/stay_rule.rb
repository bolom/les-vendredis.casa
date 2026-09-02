class StayRule < ApplicationRecord
  validates :minimum_nights, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_nil: true
  validates :maximum_nights, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_nil: true
  validates :maximum_adults, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :maximum_children, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :booking_window_days, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_nil: true
  validate :maximum_nights_not_below_minimum
  validate :allowed_weekdays_are_valid

  scope :active, -> { where(active: true) }

  def self.current
    active.order(updated_at: :desc).first || new
  end

  def validate_stay(stay)
    errors = []
    nights = (stay.check_out - stay.check_in).to_i

    errors << [ :check_out, "is shorter than the configured minimum stay" ] if minimum_nights.present? && nights < minimum_nights
    errors << [ :check_out, "is longer than the configured maximum stay" ] if maximum_nights.present? && nights > maximum_nights
    errors << [ :adults, "exceeds the configured capacity" ] if stay.adults.to_i > maximum_adults
    errors << [ :children, "exceeds the configured capacity" ] if stay.children.to_i > maximum_children
    errors << [ :check_in, "is outside the configured booking window" ] if booking_window_days.present? && stay.check_in > Date.current + booking_window_days.days
    errors << [ :check_in, "is not an allowed arrival day" ] unless allowed_check_in_on?(stay.check_in)
    errors << [ :check_out, "is not an allowed departure day" ] unless allowed_check_out_on?(stay.check_out)

    errors
  end

  def allowed_check_in_on?(date)
    allowed_weekday?(allowed_check_in_days, date)
  end

  def allowed_check_out_on?(date)
    allowed_weekday?(allowed_check_out_days, date)
  end

  private

  def maximum_nights_not_below_minimum
    return if minimum_nights.blank? || maximum_nights.blank?

    errors.add(:maximum_nights, "must be greater than or equal to minimum_nights") if maximum_nights < minimum_nights
  end

  def allowed_weekdays_are_valid
    {
      allowed_check_in_days: allowed_check_in_days,
      allowed_check_out_days: allowed_check_out_days
    }.each do |attribute, weekdays|
      next if weekdays.blank?
      next if weekdays.all? { |weekday| weekday.is_a?(Integer) && weekday.between?(0, 6) }

      errors.add(attribute, "must contain weekdays from 0 to 6")
    end
  end

  def allowed_weekday?(weekdays, date)
    weekdays.blank? || date.wday.in?(weekdays)
  end
end
