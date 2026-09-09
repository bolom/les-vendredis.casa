require "test_helper"

class CalendarExportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @original_fetch = AppConfig.method(:fetch)
    original_fetch = @original_fetch
    AppConfig.define_singleton_method(:fetch) do |env_key, *credential_path, **kwargs|
      env_key == "ICAL_EXPORT_TOKEN" ? "test-export-token" : original_fetch.call(env_key, *credential_path, **kwargs)
    end
  end

  teardown do
    AppConfig.define_singleton_method(:fetch, @original_fetch)
  end

  test "exports only blocking direct and manual availability blocks" do
    direct = create_block(starts_on: Date.new(2026, 11, 1), ends_on: Date.new(2026, 11, 3), source: "direct", kind: "direct_stay", status: "confirmed")
    manual = create_block(starts_on: Date.new(2026, 11, 5), ends_on: Date.new(2026, 11, 6), source: "manual", kind: "manual_closure", status: "tentative")
    cancelled = create_block(starts_on: Date.new(2026, 11, 8), ends_on: Date.new(2026, 11, 9), source: "manual", kind: "manual_closure", status: "cancelled")

    get calendar_export_path(token: "test-export-token")

    assert_response :success
    assert_equal "text/calendar", response.media_type
    assert_includes response.body, "BEGIN:VCALENDAR\r\n"
    assert_includes response.body, "UID:availability-block-#{direct.id}@lesvendredis.casa"
    assert_includes response.body, "DTSTART;VALUE=DATE:20261101"
    assert_includes response.body, "UID:availability-block-#{manual.id}@lesvendredis.casa"
    assert_not_includes response.body, "UID:availability-block-#{cancelled.id}@lesvendredis.casa"
    assert response.body.end_with?("END:VCALENDAR\r\n")
  end

  test "never re-exports imported calendar events" do
    calendar_import = CalendarImport.create!(provider: "airbnb")
    imported = CalendarEvent.create!(
      calendar_import: calendar_import,
      external_uid: "airbnb-private-event",
      starts_on: Date.new(2026, 12, 1),
      ends_on: Date.new(2026, 12, 4),
      status: "confirmed",
      fingerprint: "imported-fingerprint"
    )

    get calendar_export_path(token: "test-export-token")

    assert_response :success
    assert_not_includes response.body, imported.external_uid
    assert_not_includes response.body, "20261201"
  end

  test "returns not found for an invalid token" do
    get calendar_export_path(token: "wrong-token")

    assert_response :not_found
  end

  private

  def create_block(**attributes)
    AvailabilityBlock.create!(attributes)
  end
end
