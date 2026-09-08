require "test_helper"

class PaymentOrderTest < ActiveSupport::TestCase
  setup do
    @order = PaymentOrder.create!(
      public_id: "0f0e0d0c-1111-2222-3333-444455556666",
      quote: { totalPrice: "148" }.as_json,
      requirements: { scheme: "exact", network: "eip155:8453" }.as_json,
      expires_at: 15.minutes.from_now
    )
    @previous_app_host = ENV["APP_HOST"]
    ENV.delete("APP_HOST")
  end

  teardown do
    @previous_app_host.nil? ? ENV.delete("APP_HOST") : ENV["APP_HOST"] = @previous_app_host
  end

  test "challenge defaults to the production resource url" do
    challenge = @order.challenge
    assert_equal 2, challenge[:x402Version]
    assert_equal "https://lesvendredis.casa/book?quote_id=#{@order.public_id}", challenge.dig(:resource, :url)
    assert_equal "application/json", challenge.dig(:resource, :mimeType)
    assert_equal [ @order.requirements ], challenge[:accepts]
  end

  test "challenge honours APP_HOST for staging" do
    ENV["APP_HOST"] = "staging.lesvendredis.casa"
    challenge = @order.challenge
    assert_equal "https://staging.lesvendredis.casa/book?quote_id=#{@order.public_id}", challenge.dig(:resource, :url)
    assert_equal "application/json", challenge.dig(:resource, :mimeType)
  end

  test "challenge honours credentials app.host" do
    original_fetch = AppConfig.method(:fetch)
    AppConfig.define_singleton_method(:fetch) do |env_key, *credential_path, **kwargs|
      credential_path == [ :app, :host ] ? "staging.lesvendredis.casa" : original_fetch.call(env_key, *credential_path, **kwargs)
    end
    challenge = @order.challenge
    assert_equal "https://staging.lesvendredis.casa/book?quote_id=#{@order.public_id}", challenge.dig(:resource, :url)
  ensure
    AppConfig.define_singleton_method(:fetch, original_fetch)
  end

  test "challenge fails closed on an unauthorized host" do
    ENV["APP_HOST"] = "attacker.example.test"
    error = assert_raises(KeyError) { @order.challenge }
    assert_match(/unauthorized APP_HOST/i, error.message)
    ENV["APP_HOST"] = "https://lesvendredis.casa"
    assert_raises(KeyError) { @order.challenge }
  end
end
