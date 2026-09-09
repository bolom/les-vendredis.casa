require "test_helper"

class HouseStateTest < ActiveSupport::TestCase
  test "stale calendar anomaly reports the provider freshness threshold" do
    CalendarImport.create!(provider: "airbnb", last_status: "success", last_synced_at: 5.hours.ago)

    anomaly = HouseState.anomalies.find { |item| item[:kind] == "calendar_sync_stale" }

    assert_equal "airbnb has not synced in the last 4 hours.", anomaly[:message]
  end

  test "a calendar inside its freshness threshold has no stale anomaly" do
    CalendarImport.create!(provider: "airbnb", last_status: "success", last_synced_at: 2.hours.ago)

    assert_not HouseState.anomalies.any? { |item| item[:kind] == "calendar_sync_stale" }
  end
end
