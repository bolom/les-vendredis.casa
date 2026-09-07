require "test_helper"

class BookingInquiryTest < ActiveSupport::TestCase
  test "one night stay is accepted by default" do
    inquiry = BookingInquiry.new(
      check_in: Date.new(2026, 10, 1),
      check_out: Date.new(2026, 10, 2),
      adults: 2,
      children: 0,
      guest_name: "Guest",
      email: "guest@example.com",
      locale: "en"
    )

    assert inquiry.valid?
  end

  test "configured minimum stay is enforced without hard coding it" do
    StayRule.create!(minimum_nights: 2)

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
    assert_includes inquiry.errors[:check_out], "is shorter than the configured minimum stay"
  end

  test "inquiry does not create a blocking availability record" do
    assert_no_difference -> { AvailabilityBlock.count } do
      BookingInquiry.create!(
        check_in: Date.new(2026, 10, 1),
        check_out: Date.new(2026, 10, 2),
        adults: 2,
        children: 0,
        guest_name: "Guest",
        email: "guest@example.com",
        locale: "en"
      )
    end
  end
end
