require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home is public" do
    get root_path

    assert_response :success
    assert_select "h1", "Les Vendredis"
  end

  test "health check is public" do
    get rails_health_check_path

    assert_response :success
  end
end
