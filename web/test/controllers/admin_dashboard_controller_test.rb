require "test_helper"

class AdminDashboardControllerTest < ActionDispatch::IntegrationTest
  test "redirects unauthenticated visitor to the sign in page" do
    get admin_root_path

    assert_redirected_to new_session_path
  end

  test "allows an authenticated administrator" do
    sign_in_as users(:one)

    get admin_root_path

    assert_response :success
    assert_select "h1", "Admin Les Vendredis"
  end
end
