require "test_helper"

module Admin
  class CalendarImportsControllerTest < ActionDispatch::IntegrationTest
    test "sync queues a provider job and returns to the readable calendars screen" do
      sign_in_as users(:one)
      calendar_import = CalendarImport.create!(provider: "airbnb")

      post sync_admin_calendar_import_path(calendar_import)

      assert_redirected_to admin_calendars_path
      assert_match(/Synchronisation de Airbnb relancée/, flash[:notice])
    end

    test "sync requires authentication" do
      calendar_import = CalendarImport.create!(provider: "airbnb")

      post sync_admin_calendar_import_path(calendar_import)

      assert_redirected_to new_session_path
    end
  end
end
