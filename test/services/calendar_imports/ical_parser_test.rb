require "test_helper"

class CalendarImports::IcalParserTest < ActiveSupport::TestCase
  test "parses multi-day date events" do
    event = CalendarImports::IcalParser.new(ical_body(uid: "one", start: "20261001", finish: "20261004")).events.first

    assert_equal "one", event.external_uid
    assert_equal Date.new(2026, 10, 1), event.starts_on
    assert_equal Date.new(2026, 10, 4), event.ends_on
    assert_equal "confirmed", event.status
  end

  test "parses cancelled events" do
    event = CalendarImports::IcalParser.new(ical_body(status: "CANCELLED")).events.first

    assert_equal "cancelled", event.status
  end

  private

  def ical_body(uid: "uid-1", start: "20261001", finish: "20261002", status: "CONFIRMED")
    <<~ICAL
      BEGIN:VCALENDAR
      BEGIN:VEVENT
      UID:#{uid}
      DTSTART;VALUE=DATE:#{start}
      DTEND;VALUE=DATE:#{finish}
      STATUS:#{status}
      SUMMARY:Reserved
      END:VEVENT
      END:VCALENDAR
    ICAL
  end
end
