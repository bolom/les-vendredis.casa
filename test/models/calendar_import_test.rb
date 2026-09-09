require "test_helper"

class CalendarImportTest < ActiveSupport::TestCase
  test "an Airbnb import synced two hours ago is fresh by default" do
    calendar_import = CalendarImport.new(provider: "airbnb", last_synced_at: 2.hours.ago)

    assert_not calendar_import.stale?
    assert_equal 4.hours, calendar_import.freshness_threshold
  end

  test "an import beyond its provider threshold is stale" do
    calendar_import = CalendarImport.new(provider: "booking", last_synced_at: 5.hours.ago)

    assert calendar_import.stale?
  end

  test "an import that has never synced is stale" do
    assert CalendarImport.new(provider: "airbnb").stale?
  end
end
