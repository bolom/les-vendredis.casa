require "test_helper"

class AvailabilityControllerTest < ActionDispatch::IntegrationTest
  test "renders a public availability landing page without dates" do
    get availability_path

    assert_response :success
    assert_select "h1", /Check when the A-frame is free/
  end

  test "returns public availability without personal data" do
    get availability_path, params: { from: "2026-10-01", to: "2026-10-03" }

    assert_response :success
    payload = response.parsed_body
    assert_equal [
      { "date" => "2026-10-01", "available" => true },
      { "date" => "2026-10-02", "available" => true }
    ], payload.fetch("days")
    assert payload.fetch("generated_at")
    assert_not_includes payload.to_json, "guest"
    assert_not_includes payload.to_json, "email"
    assert_not_includes payload.to_json, "phone"
  end

  test "returns validation errors for invalid ranges" do
    get availability_path, params: { from: "2026-10-01", to: "2026-10-01" }

    assert_response :unprocessable_entity
    assert_includes response.parsed_body.fetch("errors"), "to must be after from"
  end
end
