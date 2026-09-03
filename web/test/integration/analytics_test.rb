require "test_helper"

class AnalyticsTest < ActionDispatch::IntegrationTest
  test "booking form tracks safe inquiry events without pii values" do
    get new_booking_inquiry_path

    assert_response :success
    assert_select "form[data-analytics-event='submit_inquiry']"
    assert_match "start_inquiry", response.body
    assert_no_match "guest_name", analytics_script_text
    assert_no_match "email", analytics_script_text
    assert_no_match "phone", analytics_script_text
    assert_no_match "message", analytics_script_text
  end

  test "booking success tracks conversion without public reference" do
    inquiry = BookingInquiry.create!(
      check_in: Date.new(2026, 10, 1),
      check_out: Date.new(2026, 10, 3),
      adults: 2,
      children: 0,
      guest_name: "Guest",
      email: "guest@example.com",
      locale: "en"
    )

    get booking_inquiry_path(inquiry.public_reference)

    assert_response :success
    assert_match "inquiry_success", analytics_script_text
    assert_no_match inquiry.public_reference, analytics_script_text
    assert_no_match inquiry.email, analytics_script_text
  end

  private

  def analytics_script_text
    response.body.scan(%r{<script>(.*?)</script>}m).flatten.join("\n")
  end
end
