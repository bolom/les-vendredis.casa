require "test_helper"

class X402ContractTest < ActionDispatch::IntegrationTest
  setup do
    @configuration = {
      "X402_ENABLED" => "true", "X402_CHAIN_ID" => "8453", "X402_DECIMALS" => "6",
      "X402_ASSET" => "0x#{'1' * 40}", "X402_PAY_TO" => "0x#{'2' * 40}",
      "X402_TOKEN_NAME" => "Euro Coin", "X402_TOKEN_VERSION" => "2",
      "X402_FACILITATOR_URL" => "https://facilitator.example.test"
    }
    @previous = @configuration.keys.index_with { |key| ENV[key] }
    @configuration.each { |key, value| ENV[key] = value }
  end

  teardown { @previous.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value } }

  test "configured endpoint serves a version two challenge bound to persisted quote" do
    post "/quote", params: { date: "2026-11-30", nights: 2, adults: 2 }, as: :json
    assert_response :success
    quote = response.parsed_body
    assert quote["paymentConfigured"]
    assert_match(/\A0x[0-9a-f]{64}\z/, quote["authorizationNonce"])
    StayRule.create!(nightly_price_eur: 100)
    post "/book", params: { quote_id: quote["quoteId"] }, as: :json
    assert_response :payment_required
    challenge = JSON.parse(Base64.strict_decode64(response.headers.fetch("PAYMENT-REQUIRED")))
    assert_equal 2, challenge["x402Version"]
    assert_equal "148000000", challenge["accepts"].first["amount"]
    assert_equal "exact", challenge["accepts"].first["scheme"]
    assert_equal "eip155:8453", challenge["accepts"].first["network"]
    assert_nil response.headers["WWW-Authenticate"]
    travel 16.minutes
    post "/book", params: { quote_id: quote["quoteId"] }, as: :json
    assert_response :gone
  end

  test "missing recipient and invalid token configuration never advertise payment" do
    ENV["X402_PAY_TO"] = ""
    post "/book", as: :json
    assert_response :service_unavailable
    assert_nil response.headers["PAYMENT-REQUIRED"]
    get "/rules"
    assert_equal false, response.parsed_body["paymentConfigured"]
  end

  test "admin price is shared by availability and quote" do
    StayRule.create!(nightly_price_eur: "85.50")
    get "/availability", params: { from: "2026-11-30", to: "2026-12-02" }
    assert_equal "85.5", response.parsed_body["days"].first["price"]
    post "/quote", params: { date: "2026-11-30", nights: 2, adults: 2 }, as: :json
    assert_equal "171", response.parsed_body["totalPrice"]
  end
end
