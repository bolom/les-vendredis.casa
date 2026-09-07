require "test_helper"
require "base64"
require "json"

class MachineBookingsControllerTest < ActionDispatch::IntegrationTest
  test "rules exposes direct booking payment configuration" do
    get "/rules"

    assert_response :success
    body = response.parsed_body
    assert_equal 1, body["minNights"]
    assert_equal 3, body["maxGuests"]
    assert_equal "74", body["price"]
    assert_equal "EURC", body["currency"]
    assert_equal "polygon", body["network"]
  end

  test "quote returns availability and payment amount" do
    post "/quote", params: { date: "2026-11-30", nights: 2, guests: 2 }, as: :json

    assert_response :success
    body = response.parsed_body
    assert_equal "2026-11-30", body["date"]
    assert_equal "2026-12-02", body["checkOut"]
    assert_equal 2, body["nights"]
    assert_equal "148", body["totalPrice"]
    assert_equal "EURC", body["asset"]
  end

  test "quote rejects unavailable dates" do
    AvailabilityBlock.create!(
      starts_on: Date.new(2026, 11, 30),
      ends_on: Date.new(2026, 12, 2),
      kind: "direct_stay",
      source: "direct",
      status: "confirmed",
      summary: "Existing stay"
    )

    post "/quote", params: { date: "2026-11-30", nights: 2, guests: 2 }, as: :json

    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"], "dates are not available"
  end

  test "explicit adults and children respect separate capacities" do
    post "/quote", params: { date: "2026-11-30", nights: 2, adults: 2, children: 1 }, as: :json
    assert_response :success
    assert_equal 3, response.parsed_body["guests"]
    post "/quote", params: { date: "2026-11-30", nights: 2, adults: 3, children: 0 }, as: :json
    assert_response :unprocessable_entity
  end

  test "book is unavailable until payment verification exists" do
    assert_no_difference "BookingInquiry.count" do
      assert_no_difference "AvailabilityBlock.count" do
        post "/book", params: { date: "2026-11-30", nights: 2, guests: 2 }, as: :json
      end
    end

    assert_response :service_unavailable
    assert_equal "payment_unavailable", response.parsed_body["error"]
    assert_nil response.headers["WWW-Authenticate"]
  end

  test "rejects past dates fractional counts and excess adults" do
    [ { date: Date.yesterday.iso8601 }, { nights: 1.9 }, { guests: 2.9 }, { guests: 3 }, { nights: [] } ].each do |invalid|
      post "/quote", params: { date: "2026-11-30", nights: 2, guests: 2 }.merge(invalid), as: :json
      assert_response :unprocessable_entity
    end
  end
end
