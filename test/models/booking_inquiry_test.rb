require "test_helper"

class BookingInquiryTest < ActiveSupport::TestCase
  test "acceptance snapshots the configured prices" do
    StayRule.current.update!(nightly_price_eur: 68, airbnb_nightly_price_eur: 71)
    inquiry = BookingInquiry.create!(
      check_in: Date.new(2027, 2, 1),
      check_out: Date.new(2027, 2, 3),
      adults: 2,
      children: 0,
      guest_name: "Guest",
      email: "guest@example.com",
      locale: "en"
    )

    inquiry.accept!

    assert_equal 68, inquiry.accepted_nightly_price_eur
    assert_equal 136, inquiry.accepted_total_price_eur
    assert_equal 71, inquiry.accepted_airbnb_nightly_price_eur
  end

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
