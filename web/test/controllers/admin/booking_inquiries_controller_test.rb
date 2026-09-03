require "test_helper"

module Admin
  class BookingInquiriesControllerTest < ActionDispatch::IntegrationTest
    include ActiveJob::TestHelper

    test "admin can see inquiries" do
      sign_in_as users(:one)
      inquiry = create_inquiry

      get admin_booking_inquiries_path

      assert_response :success
      assert_select "a", inquiry.public_reference
    end

    test "admin accept creates confirmed availability block" do
      sign_in_as users(:one)
      inquiry = create_inquiry

      assert_enqueued_emails 1 do
        post accept_admin_booking_inquiry_path(inquiry)
      end

      assert_redirected_to admin_booking_inquiries_path
      inquiry.reload
      assert_equal "accepted", inquiry.status
      assert_equal "confirmed", inquiry.availability_block.status
      assert_equal Date.new(2026, 10, 1), inquiry.availability_block.starts_on
    end

    test "admin accept fails when dates became unavailable" do
      sign_in_as users(:one)
      inquiry = create_inquiry
      AvailabilityBlock.create!(
        starts_on: Date.new(2026, 10, 1),
        ends_on: Date.new(2026, 10, 3),
        kind: "manual_closure",
        source: "manual",
        status: "confirmed"
      )

      post accept_admin_booking_inquiry_path(inquiry)

      assert_redirected_to admin_booking_inquiry_path(inquiry)
      assert_equal "new", inquiry.reload.status
    end

    test "admin can decline inquiry without blocking dates" do
      sign_in_as users(:one)
      inquiry = create_inquiry

      assert_no_difference -> { AvailabilityBlock.count } do
        assert_enqueued_emails 1 do
          post decline_admin_booking_inquiry_path(inquiry)
        end
      end

      assert_equal "declined", inquiry.reload.status
    end

    private

    def create_inquiry
      BookingInquiry.create!(
        check_in: Date.new(2026, 10, 1),
        check_out: Date.new(2026, 10, 3),
        adults: 2,
        children: 0,
        guest_name: "Guest",
        email: "guest@example.com",
        locale: "en"
      )
    end
  end
end
