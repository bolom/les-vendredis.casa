require "test_helper"

module Admin
  class StayRulesControllerTest < ActionDispatch::IntegrationTest
    test "requires authentication" do
      get edit_admin_stay_rule_path

      assert_redirected_to new_session_path
    end

    test "admin can update stay rules and public validation changes immediately" do
      sign_in_as users(:one)

      patch admin_stay_rule_path, params: {
        stay_rule: {
          minimum_nights: 2,
          maximum_nights: "",
          maximum_adults: 2,
          maximum_children: 1,
          pets_allowed: "1",
          booking_window_days: "",
          allowed_check_in_days: %w[1 2 3 4 5],
          allowed_check_out_days: %w[1 2 3 4 5]
        }
      }

      assert_redirected_to edit_admin_stay_rule_path
      assert_equal 2, StayRule.current.minimum_nights

      inquiry = BookingInquiry.new(
        check_in: Date.new(2026, 10, 1),
        check_out: Date.new(2026, 10, 2),
        adults: 2,
        children: 0,
        guest_name: "Guest",
        email: "guest@example.com",
        locale: "en"
      )
      assert_not inquiry.valid?
    end
  end
end
