require "test_helper"

class BookingInquiriesControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "creates non blocking inquiry and queues emails" do
    assert_enqueued_jobs 2 do
      post booking_inquiries_path, params: {
        locale: "en",
        booking_inquiry: valid_params
      }
    end

    inquiry = BookingInquiry.last
    assert_redirected_to booking_inquiry_path(inquiry.public_reference)
    assert_equal "new", inquiry.status
    assert_nil inquiry.availability_block
    assert_equal 0, AvailabilityBlock.count
  end

  test "does not save inquiry when dates are no longer available" do
    AvailabilityBlock.create!(
      starts_on: Date.new(2026, 10, 1),
      ends_on: Date.new(2026, 10, 3),
      kind: "manual_closure",
      source: "manual",
      status: "confirmed"
    )

    assert_no_difference -> { BookingInquiry.count } do
      post booking_inquiries_path, params: {
        booking_inquiry: valid_params
      }
    end

    assert_response :unprocessable_entity
  end

  test "honeypot rejects spam without saving" do
    assert_no_difference -> { BookingInquiry.count } do
      post booking_inquiries_path, params: {
        company: "bot",
        booking_inquiry: valid_params
      }
    end

    assert_redirected_to new_booking_inquiry_path
  end

  private

  def valid_params
    {
      check_in: "2026-10-01",
      check_out: "2026-10-03",
      adults: 2,
      children: 0,
      guest_name: "Guest",
      email: "guest@example.com",
      phone: "+596696000000",
      message: "Hello"
    }
  end
end
