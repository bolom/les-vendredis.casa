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

  test "book requires x402 payment before confirmation" do
    assert_no_difference "BookingInquiry.count" do
      assert_no_difference "AvailabilityBlock.count" do
        post "/book", params: { date: "2026-11-30", nights: 2, guests: 2 }, as: :json
      end
    end

    assert_response :payment_required
    body = response.parsed_body
    assert_equal "payment_required", body["error"]
    assert_equal "x402", body["paymentMethods"].first["scheme"]
    assert_equal "148000000", body["paymentMethods"].first["amount"]

    auth_scheme, encoded = response.headers.fetch("WWW-Authenticate").match(/\A(\w+) request="([^"]+)"\z/).captures
    assert_equal "Payment", auth_scheme
    challenge = JSON.parse(Base64.strict_decode64(encoded))
    assert_equal "148000000", challenge["amount"]
    assert_equal "EURC", challenge["asset"]
    assert_equal "polygon", challenge["network"]
  end
end
