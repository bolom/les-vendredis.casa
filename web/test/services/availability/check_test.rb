require "test_helper"

class Availability::CheckTest < ActiveSupport::TestCase
  test "returns available days for an open range" do
    check = Availability::Check.new(from: "2026-10-01", to: "2026-10-03")

    assert check.valid?
    assert_equal [
      { date: "2026-10-01", available: true },
      { date: "2026-10-02", available: true }
    ], check.days
  end

  test "marks blocked nights unavailable" do
    AvailabilityBlock.create!(
      starts_on: Date.new(2026, 10, 2),
      ends_on: Date.new(2026, 10, 4),
      kind: "manual_closure",
      source: "manual",
      status: "confirmed"
    )

    check = Availability::Check.new(from: "2026-10-01", to: "2026-10-05")

    assert_equal [
      { date: "2026-10-01", available: true },
      { date: "2026-10-02", available: false },
      { date: "2026-10-03", available: false },
      { date: "2026-10-04", available: true }
    ], check.days
  end

  test "active imported calendar events block availability" do
    calendar_import = CalendarImport.create!(provider: "airbnb", active: true)
    CalendarEvent.create!(
      calendar_import: calendar_import,
      external_uid: "airbnb-1",
      starts_on: Date.new(2026, 10, 2),
      ends_on: Date.new(2026, 10, 3),
      status: "confirmed",
      fingerprint: "abc"
    )

    check = Availability::Check.new(from: "2026-10-02", to: "2026-10-03")

    assert_equal [ { date: "2026-10-02", available: false } ], check.days
  end

  test "inactive imported calendar events do not block availability" do
    calendar_import = CalendarImport.create!(provider: "booking", active: false)
    CalendarEvent.create!(
      calendar_import: calendar_import,
      external_uid: "booking-1",
      starts_on: Date.new(2026, 10, 2),
      ends_on: Date.new(2026, 10, 3),
      status: "confirmed",
      fingerprint: "abc"
    )

    check = Availability::Check.new(from: "2026-10-02", to: "2026-10-03")

    assert_equal [ { date: "2026-10-02", available: true } ], check.days
  end

  test "rejects invalid and too long ranges" do
    invalid = Availability::Check.new(from: "not-a-date", to: "2026-10-03")
    too_long = Availability::Check.new(from: "2026-10-01", to: "2027-01-15")

    assert_not invalid.valid?
    assert_includes invalid.errors, "from must be an ISO date"
    assert_not too_long.valid?
    assert_includes too_long.errors, "range cannot exceed 93 days"
  end
end
