require "test_helper"

class AvailabilityBlockTest < ActiveSupport::TestCase
  test "allows a stay to start on the checkout day of another stay" do
    AvailabilityBlock.create!(
      starts_on: Date.new(2026, 10, 1),
      ends_on: Date.new(2026, 10, 3),
      kind: "direct_stay",
      source: "direct",
      status: "confirmed"
    )

    next_stay = AvailabilityBlock.new(
      starts_on: Date.new(2026, 10, 3),
      ends_on: Date.new(2026, 10, 5),
      kind: "direct_stay",
      source: "direct",
      status: "confirmed"
    )

    assert next_stay.valid?
  end

  test "rejects overlapping blocking stays" do
    AvailabilityBlock.create!(
      starts_on: Date.new(2026, 10, 1),
      ends_on: Date.new(2026, 10, 5),
      kind: "manual_closure",
      source: "manual",
      status: "confirmed"
    )

    overlap = AvailabilityBlock.new(
      starts_on: Date.new(2026, 10, 4),
      ends_on: Date.new(2026, 10, 7),
      kind: "direct_stay",
      source: "direct",
      status: "confirmed"
    )

    assert_not overlap.valid?
    assert_includes overlap.errors[:base], "availability block overlaps an existing blocking stay"
  end

  test "cancelled stays do not block dates" do
    AvailabilityBlock.create!(
      starts_on: Date.new(2026, 10, 1),
      ends_on: Date.new(2026, 10, 5),
      kind: "direct_stay",
      source: "direct",
      status: "cancelled"
    )

    replacement = AvailabilityBlock.new(
      starts_on: Date.new(2026, 10, 2),
      ends_on: Date.new(2026, 10, 4),
      kind: "direct_stay",
      source: "direct",
      status: "confirmed"
    )

    assert replacement.valid?
  end

  test "a direct stay linked to an unresolved payment refuses any status change" do
    inquiry = BookingInquiry.create!(
      check_in: Date.new(2026, 10, 1),
      check_out: Date.new(2026, 10, 3),
      adults: 2,
      guest_name: "Test Guest",
      email: "guest@example.com",
      locale: "en"
    )
    block = AvailabilityBlock.create!(
      starts_on: Date.new(2026, 10, 1),
      ends_on: Date.new(2026, 10, 3),
      kind: "direct_stay",
      source: "direct",
      status: "tentative"
    )
    inquiry.update_column(:availability_block_id, block.id)
    PaymentOrder.create!(
      quote: { totalPrice: "148" }.as_json,
      requirements: { scheme: "exact" }.as_json,
      expires_at: 15.minutes.from_now,
      status: "settling",
      booking_inquiry_id: inquiry.id,
      availability_block_id: block.id
    )

    block.status = "confirmed"
    assert_not block.save
    assert_includes block.errors[:base], "Reconcile the payment before changing this block's status"
    assert_equal "tentative", block.reload.status
  end

  test "a direct stay refuses status and date changes outside the business path" do
    block = AvailabilityBlock.create!(
      starts_on: Date.new(2026, 10, 1),
      ends_on: Date.new(2026, 10, 3),
      kind: "direct_stay",
      source: "direct",
      status: "tentative"
    )

    block.status = "confirmed"
    assert_not block.save
    assert_includes block.errors[:base], "This stay's status is managed by its booking; use the booking actions"
    assert_equal "tentative", block.reload.status

    block.starts_on = Date.new(2026, 10, 2)
    assert_not block.save
    assert_includes block.errors[:base], "This stay's dates are managed by its booking"
  end

  test "a manual block stays freely editable" do
    block = AvailabilityBlock.create!(
      starts_on: Date.new(2026, 10, 8),
      ends_on: Date.new(2026, 10, 9),
      kind: "manual_closure",
      source: "manual",
      status: "confirmed"
    )

    assert block.update(status: "tentative", note: "waiting on plumber")
    assert_equal "tentative", block.reload.status
  end
end
