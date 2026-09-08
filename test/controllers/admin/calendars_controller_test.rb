require "test_helper"

module Admin
  class CalendarsControllerTest < ActionDispatch::IntegrationTest
    test "requires authentication" do
      get admin_calendars_path

      assert_redirected_to new_session_path
    end

    test "shows a simple per-platform state in human language" do
      sign_in_as users(:one)
      CalendarImport.create!(provider: "airbnb", last_status: "success", last_synced_at: 4.minutes.ago, last_event_count: 3)
      CalendarImport.create!(provider: "booking", last_status: "failed", last_error_at: 1.hour.ago, last_error_message: "HTTP 500")

      get admin_calendars_path

      assert_response :success
      assert_select ".admin-state--ok", text: /À jour · synchronisé il y a 4 min/
      assert_select ".admin-state--problem", text: /Problème · dernière synchronisation échouée/
      assert_select "td", text: "Airbnb"
      assert_select "td", text: "Booking.com"
      assert_select "form[action='#{sync_admin_calendar_import_path(CalendarImport.find_by(provider: "airbnb"))}'] [data-lv-confirm]"
    end

    test "sync redirects to the calendars screen with a human notice" do
      sign_in_as users(:one)
      calendar_import = CalendarImport.create!(provider: "airbnb")

      post sync_admin_calendar_import_path(calendar_import)

      assert_redirected_to admin_calendars_path
      assert_match(/Synchronisation de Airbnb relancée/, flash[:notice])
    end
  end
end
