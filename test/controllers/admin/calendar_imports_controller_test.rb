require "test_helper"

module Admin
  class CalendarImportsControllerTest < ActionDispatch::IntegrationTest
    test "index creates provider rows and displays sync state" do
      sign_in_as users(:one)

      get admin_calendar_imports_path

      assert_response :success
      assert_select "td", "airbnb"
      assert_select "td", "booking"
    end

    test "sync queues a provider job" do
      sign_in_as users(:one)
      calendar_import = CalendarImport.create!(provider: "airbnb")

      post sync_admin_calendar_import_path(calendar_import)

      assert_redirected_to admin_calendar_imports_path
    end
  end
end
