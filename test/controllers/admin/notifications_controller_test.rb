require "test_helper"

module Admin
  class NotificationsControllerTest < ActionDispatch::IntegrationTest
    test "redirects accounts without technical access" do
      sign_in_as users(:two)

      get admin_notifications_path

      assert_redirected_to admin_root_path
    end

    test "requires authentication" do
      get admin_notifications_path

      assert_redirected_to new_session_path
    end

    test "lists failed notifications with their error" do
      sign_in_as users(:one)
      inquiry = BookingInquiry.create!(
        check_in: Date.new(2026, 10, 1),
        check_out: Date.new(2026, 10, 3),
        adults: 2,
        guest_name: "Guest",
        email: "guest@example.com",
        locale: "en"
      )
      notification = BookingNotification.find_by!(booking_inquiry: inquiry, event: "owner_notification")
      notification.update!(sent_at: nil, attempts: 2, last_error: "SMTP unreachable")

      get admin_notifications_path

      assert_response :success
      assert_select "td", text: /SMTP unreachable/
      assert_select "td", text: "owner_notification"
    end

    test "shows an empty state when nothing failed" do
      sign_in_as users(:one)

      get admin_notifications_path

      assert_response :success
      assert_select ".admin-definition", text: /Aucune notification en échec/
    end
  end
end
