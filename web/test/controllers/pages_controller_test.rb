require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home is public" do
    get root_path

    assert_response :success
    assert_select "html[lang=en]"
    assert_select "h1", /Les Vendredis is the real life/
    assert_select "a[href='#{new_booking_inquiry_path}']"
  end

  test "french home is public" do
    get french_home_path

    assert_response :success
    assert_select "html[lang=fr]"
    assert_select "h1", /Les Vendredis, c’est la vraie vie/
  end

  test "health check is public" do
    get rails_health_check_path

    assert_response :success
  end
end
