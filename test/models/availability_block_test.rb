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
end
