require "test_helper"

class BookingInquiryMailerTest < ActionMailer::TestCase
  test "owner notification includes admin link" do
    inquiry = create_inquiry
    mail = BookingInquiryMailer.with(booking_inquiry: inquiry).owner_notification

    assert_equal [ "hello@lesvendredis.casa" ], mail.to
    assert_match inquiry.public_reference, mail.subject
    assert_match Rails.application.routes.url_helpers.admin_booking_inquiry_path(inquiry), mail.body.encoded
  end

  test "guest acknowledgement says request is not confirmed" do
    inquiry = create_inquiry
    mail = BookingInquiryMailer.with(booking_inquiry: inquiry).guest_acknowledgement

    assert_equal [ "guest@example.com" ], mail.to
    assert_equal [ "hello@lesvendredis.casa" ], mail.reply_to
    assert_match "not confirmed yet", mail.body.encoded
  end

  test "guest acceptance confirms the stay" do
    inquiry = create_inquiry
    mail = BookingInquiryMailer.with(booking_inquiry: inquiry).guest_acceptance

    assert_equal [ "guest@example.com" ], mail.to
    assert_match "confirmed", mail.subject
    assert_match "is confirmed", mail.body.encoded
  end

  test "guest decline does not expose admin details" do
    inquiry = create_inquiry
    mail = BookingInquiryMailer.with(booking_inquiry: inquiry).guest_decline

    assert_equal [ "guest@example.com" ], mail.to
    assert_no_match "Admin", mail.body.encoded
    assert_no_match "http", mail.body.encoded
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
