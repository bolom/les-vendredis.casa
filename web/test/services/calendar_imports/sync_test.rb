require "test_helper"

class CalendarImports::SyncTest < ActiveSupport::TestCase
  test "imports events idempotently" do
    calendar_import = CalendarImport.create!(provider: "airbnb")

    with_ical_env("AIRBNB_ICAL_URL") do
      2.times { CalendarImports::Sync.new(calendar_import, fetcher: ->(_url) { ical_body(uid: "same") }).call }
    end

    assert_equal 1, calendar_import.calendar_events.count
    calendar_import.reload
    assert_equal "success", calendar_import.last_status
    assert_equal 1, calendar_import.last_event_count
  end

  test "updates changed events and cancels events missing after a successful sync" do
    calendar_import = CalendarImport.create!(provider: "booking")

    with_ical_env("BOOKING_ICAL_URL") do
      CalendarImports::Sync.new(calendar_import, fetcher: ->(_url) { ical_body(uid: "old") + ical_body(uid: "changed") }).call
      CalendarImports::Sync.new(calendar_import, fetcher: ->(_url) { ical_body(uid: "changed", start: "20261003", finish: "20261005") }).call
    end

    assert_equal "cancelled", calendar_import.calendar_events.find_by!(external_uid: "old").status
    changed = calendar_import.calendar_events.find_by!(external_uid: "changed")
    assert_equal Date.new(2026, 10, 3), changed.starts_on
    assert_equal Date.new(2026, 10, 5), changed.ends_on
  end

  test "failed sync preserves existing events" do
    calendar_import = CalendarImport.create!(provider: "airbnb")

    with_ical_env("AIRBNB_ICAL_URL") do
      CalendarImports::Sync.new(calendar_import, fetcher: ->(_url) { ical_body(uid: "kept") }).call

      assert_raises(RuntimeError) do
        CalendarImports::Sync.new(calendar_import, fetcher: ->(_url) { raise "timeout" }).call
      end
    end

    assert_equal "confirmed", calendar_import.calendar_events.find_by!(external_uid: "kept").status
    assert_equal "failed", calendar_import.reload.last_status
  end

  test "imported event blocks public availability" do
    calendar_import = CalendarImport.create!(provider: "airbnb")

    with_ical_env("AIRBNB_ICAL_URL") do
      CalendarImports::Sync.new(calendar_import, fetcher: ->(_url) { ical_body(uid: "busy") }).call
    end

    check = Availability::Check.new(from: "2026-10-01", to: "2026-10-02")

    assert_equal [ { date: "2026-10-01", available: false } ], check.days
  end

  private

  def with_ical_env(key)
    old = ENV[key]
    ENV[key] = "https://example.test/calendar.ics"
    yield
  ensure
    ENV[key] = old
  end

  def ical_body(uid:, start: "20261001", finish: "20261002")
    <<~ICAL
      BEGIN:VCALENDAR
      BEGIN:VEVENT
      UID:#{uid}
      DTSTART;VALUE=DATE:#{start}
      DTEND;VALUE=DATE:#{finish}
      STATUS:CONFIRMED
      SUMMARY:Reserved
      END:VEVENT
      END:VCALENDAR
    ICAL
  end
end
