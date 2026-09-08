require "test_helper"

module Admin
  class DiagnosticsControllerTest < ActionDispatch::IntegrationTest
    test "redirects accounts without technical access" do
      sign_in_as users(:two)

      get admin_diagnostics_path

      assert_redirected_to admin_root_path
    end

    test "requires authentication" do
      get admin_diagnostics_path

      assert_redirected_to new_session_path
    end

    test "shows raw synchronization details for the technical zone" do
      sign_in_as users(:one)
      CalendarImport.create!(provider: "airbnb", last_status: "success", last_synced_at: 4.minutes.ago, last_duration_ms: 850, last_event_count: 3)

      get admin_diagnostics_path

      assert_response :success
      assert_select "td", text: "airbnb"
      assert_select "td", text: /850 ms/
      assert_select "td", text: /3 dernier cycle/
    end
  end
end
