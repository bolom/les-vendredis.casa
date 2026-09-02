module Admin
  class StayRulesController < ApplicationController
    def edit
      @stay_rule = StayRule.current
    end

    def update
      @stay_rule = StayRule.current

      if @stay_rule.persisted? ? @stay_rule.update(stay_rule_params) : @stay_rule.update(stay_rule_params.merge(active: true))
        redirect_to edit_admin_stay_rule_path, notice: "Stay rules updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def stay_rule_params
      permitted = params.require(:stay_rule).permit(
        :minimum_nights,
        :maximum_nights,
        :maximum_adults,
        :maximum_children,
        :pets_allowed,
        :booking_window_days,
        allowed_check_in_days: [],
        allowed_check_out_days: []
      )
      %i[minimum_nights maximum_nights booking_window_days].each { |key| permitted[key] = nil if permitted[key].blank? }
      %i[allowed_check_in_days allowed_check_out_days].each do |key|
        permitted[key] = permitted[key]&.reject(&:blank?)&.map(&:to_i).presence
      end
      permitted
    end
  end
end
