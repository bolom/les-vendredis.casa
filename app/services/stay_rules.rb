# frozen_string_literal: true

# Shared stay-rules updates for the human admin and the agent API. Same
# "current rule, create on first save" behavior as the HTML controller, so
# both surfaces produce identical records.
module StayRules
  class Error < StandardError; end

  NORMALIZED_FIELDS = {
    integer_optional: %i[minimum_nights maximum_nights booking_window_days],
    weekday_arrays: %i[allowed_check_in_days allowed_check_out_days]
  }.freeze

  PERMITTED = %i[
    nightly_price_eur
    airbnb_nightly_price_eur
    minimum_nights
    maximum_nights
    maximum_adults
    maximum_children
    pets_allowed
    booking_window_days
  ] + NORMALIZED_FIELDS[:weekday_arrays]

  module_function

  def update(attributes)
    stay_rule = StayRule.current
    stay_rule.assign_attributes(normalize(attributes))
    if stay_rule.persisted? ? stay_rule.save! : stay_rule.save!
      stay_rule
    end
  rescue ActiveRecord::RecordInvalid => error
    raise Error, error.record.errors.full_messages.to_sentence
  end

  def normalize(attributes)
    permitted = attributes.slice(*PERMITTED).compact
    NORMALIZED_FIELDS[:integer_optional].each do |key|
      permitted[key] = nil if permitted[key].blank?
    end
    NORMALIZED_FIELDS[:weekday_arrays].each do |key|
      value = permitted[key]
      permitted[key] = Array(value).reject(&:blank?).map(&:to_i).presence if value
    end
    permitted
  end
end
