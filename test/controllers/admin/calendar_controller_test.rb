require "test_helper"

module Admin
  class CalendarControllerTest < ActionDispatch::IntegrationTest
    test "requires authentication" do
      get admin_calendar_path

      assert_redirected_to new_session_path
    end

    test "shows a monthly grid combining every blocking origin" do
      sign_in_as users(:one)
      AvailabilityBlock.create!(
        starts_on: Date.new(2026, 10, 5),
        ends_on: Date.new(2026, 10, 8),
        kind: "manual_closure",
        source: "manual",
        status: "confirmed",
        summary: "Peinture"
      )
      AvailabilityBlock.create!(
        starts_on: Date.new(2026, 10, 12),
        ends_on: Date.new(2026, 10, 17),
        kind: "direct_stay",
        source: "direct",
        status: "confirmed",
        summary: "Séjour direct LV-TEST"
      )
      imported = CalendarImport.create!(provider: "airbnb")
      CalendarEvent.create!(
        calendar_import: imported,
        external_uid: "evt-1",
        starts_on: Date.new(2026, 10, 20),
        ends_on: Date.new(2026, 10, 23),
        status: "confirmed",
        fingerprint: "fp-1",
        summary: "Airbnb guest"
      )

      get admin_calendar_path(year: 2026, month: 10)

      assert_response :success
      assert_select ".admin-day-segment--manual_closure", text: /Peinture/
      assert_select ".admin-day-segment--direct_stay", text: /Séjour direct LV-TEST/
      assert_select ".admin-day-segment--airbnb", text: /Airbnb guest/
      assert_select "strong", text: "1"
      assert_select "strong", text: "31"
    end

    test "cancelled blocks and events never appear on the grid" do
      sign_in_as users(:one)
      AvailabilityBlock.create!(
        starts_on: Date.new(2026, 10, 5),
        ends_on: Date.new(2026, 10, 8),
        kind: "manual_closure",
        source: "manual",
        status: "cancelled"
      )

      get admin_calendar_path(year: 2026, month: 10)

      assert_select ".admin-calendar .admin-day-segment", count: 0
    end

    test "previous and next month navigation links are offered" do
      sign_in_as users(:one)

      get admin_calendar_path(year: 2026, month: 10)

      assert_select "a[href='#{admin_calendar_path(year: 2026, month: 9)}']"
      assert_select "a[href='#{admin_calendar_path(year: 2026, month: 11)}']"
    end

    test "invalid month params fall back to the current month" do
      sign_in_as users(:one)

      get admin_calendar_path(year: "9999", month: "99")

      assert_response :success
    end

    test "day endpoint returns human entries with cancel action for manual closures" do
      sign_in_as users(:one)
      block = AvailabilityBlock.create!(
        starts_on: Date.new(2026, 10, 5),
        ends_on: Date.new(2026, 10, 8),
        kind: "manual_closure",
        source: "manual",
        status: "confirmed",
        summary: "Peinture"
      )
      AvailabilityBlock.create!(
        starts_on: Date.new(2026, 10, 12),
        ends_on: Date.new(2026, 10, 17),
        kind: "direct_stay",
        source: "direct",
        status: "confirmed",
        summary: "Séjour direct LV-TEST"
      )

      get admin_calendar_day_path, params: { date: "2026-10-06" }, as: :json

      assert_response :success
      entries = response.parsed_body.fetch("entries")
      assert_equal 1, entries.length
      assert_equal "Peinture", entries.first.fetch("occupant")
      assert_equal "Blocage maison", entries.first.fetch("origin_label")
      assert_equal cancel_admin_availability_block_path(block), entries.first.fetch("cancel_url")

      get admin_calendar_day_path, params: { date: "2026-10-13" }, as: :json

      entries = response.parsed_body.fetch("entries")
      assert_equal "Séjour direct", entries.first.fetch("origin_label")
      assert_nil entries.first.fetch("cancel_url")
    end

    test "day endpoint rejects malformed dates" do
      sign_in_as users(:one)

      get admin_calendar_day_path, params: { date: "not-a-date" }, as: :json

      assert_response :bad_request
    end

    test "day endpoint requires authentication" do
      get admin_calendar_day_path, params: { date: "2026-10-06" }, as: :json

      assert_redirected_to new_session_path
    end
  end
end
