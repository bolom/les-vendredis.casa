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

    test "admin can filter and search inquiries" do
      sign_in_as users(:one)
      inquiry = create_inquiry

      get admin_booking_inquiries_path, params: { status: "new" }
      assert_select "a", inquiry.public_reference

      get admin_booking_inquiries_path, params: { status: "declined" }
      assert_select "a", { text: inquiry.public_reference, count: 0 }

      get admin_booking_inquiries_path, params: { q: inquiry.public_reference }
      assert_select "a", inquiry.public_reference

      get admin_booking_inquiries_path, params: { q: "personne" }
      assert_select "a", { text: inquiry.public_reference, count: 0 }
    end

    test "accept and decline ask for confirmation" do
      sign_in_as users(:one)
      inquiry = create_inquiry

      get admin_booking_inquiry_path(inquiry)

      assert_select "form[action='#{accept_admin_booking_inquiry_path(inquiry)}'] [data-lv-confirm]"
      assert_select "form[action='#{decline_admin_booking_inquiry_path(inquiry)}'] [data-lv-confirm]"
    end

    test "admin accept creates confirmed availability block" do
      sign_in_as users(:one)
      inquiry = create_inquiry

      assert_enqueued_jobs 1, only: BookingNotificationJob do
        post accept_admin_booking_inquiry_path(inquiry)
      end

      assert_redirected_to admin_booking_inquiry_path(inquiry)
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
        assert_enqueued_jobs 1, only: BookingNotificationJob do
          post decline_admin_booking_inquiry_path(inquiry)
        end
      end

      assert_equal "declined", inquiry.reload.status
    end

    test "repeated acceptance is idempotent and decline cannot undo acceptance" do
      inquiry = create_inquiry
      inquiry.accept!
      assert_no_difference "AvailabilityBlock.count" do
        assert_equal false, inquiry.accept!
      end
      assert_raises(ActiveRecord::RecordInvalid) { inquiry.decline! }
      assert inquiry.reload.status_accepted?
      inquiry.availability_block.update!(status: "cancelled")
      assert inquiry.reload.status_cancelled?
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
