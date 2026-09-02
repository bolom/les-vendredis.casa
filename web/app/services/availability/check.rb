module Availability
  class Check
    MAX_RANGE_DAYS = 93

    attr_reader :from, :to

    def initialize(from:, to:, stay_rule: StayRule.current)
      @from = coerce_date(from)
      @to = coerce_date(to)
      @stay_rule = stay_rule
    end

    def valid?
      errors.empty?
    end

    def errors
      @errors ||= validate_range
    end

    def days
      return [] unless valid?

      (from...to).map do |date|
        { date: date.iso8601, available: available_night?(date) }
      end
    end

    def available?(check_in:, check_out:)
      check_in = coerce_date(check_in)
      check_out = coerce_date(check_out)
      return false if check_in.blank? || check_out.blank? || check_out <= check_in

      requested_stay = Struct.new(:check_in, :check_out, :adults, :children).new(check_in, check_out, 1, 0)
      @stay_rule.validate_stay(requested_stay).empty? && !blocked?(check_in, check_out)
    end

    private

    def validate_range
      messages = []
      messages << "from must be an ISO date" if from.blank?
      messages << "to must be an ISO date" if to.blank?
      return messages if messages.any?

      messages << "to must be after from" unless to > from
      messages << "range cannot exceed #{MAX_RANGE_DAYS} days" if (to - from).to_i > MAX_RANGE_DAYS
      messages
    end

    def available_night?(date)
      date >= Date.current && !blocked?(date, date + 1.day)
    end

    def blocked?(starts_on, ends_on)
      AvailabilityBlock.blocking.overlapping(starts_on, ends_on).exists? ||
        CalendarEvent.blocking.overlapping(starts_on, ends_on).exists?
    end

    def coerce_date(value)
      return value if value.is_a?(Date)

      Date.iso8601(value.to_s)
    rescue ArgumentError, TypeError
      nil
    end
  end
end
