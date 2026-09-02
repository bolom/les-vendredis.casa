require "test_helper"

class TimeZoneTest < ActiveSupport::TestCase
  test "uses Martinique as the business time zone and stores timestamps in UTC" do
    assert_equal "America/Martinique", Rails.application.config.time_zone
    assert_equal :utc, Rails.application.config.active_record.default_timezone
  end
end
