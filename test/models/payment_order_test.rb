require "test_helper"

class PaymentOrderTest < ActiveSupport::TestCase
  setup do
    @order = PaymentOrder.create!(
      public_id: "0f0e0d0c-1111-2222-3333-444455556666",
      quote: { totalPrice: "148" }.as_json,
      requirements: { scheme: "exact", network: "eip155:8453" }.as_json,
      expires_at: 15.minutes.from_now
    )
  end

  test "challenge defaults to the production resource url" do
    challenge = with_app_host("lesvendredis.casa") { @order.challenge }
    assert_equal 2, challenge[:x402Version]
    assert_equal "https://lesvendredis.casa/book?quote_id=#{@order.public_id}", challenge.dig(:resource, :url)
    assert_equal "application/json", challenge.dig(:resource, :mimeType)
    assert_equal [ @order.requirements ], challenge[:accepts]
  end

  test "challenge rejects the retired staging host" do
    error = assert_raises(KeyError) do
      with_app_host("staging.lesvendredis.casa") { @order.challenge }
    end
    assert_match(/unauthorized APP_HOST/i, error.message)
  end

  test "challenge honours credentials app.host" do
    challenge = with_app_host("lesvendredis.casa") { @order.challenge }
    assert_equal "https://lesvendredis.casa/book?quote_id=#{@order.public_id}", challenge.dig(:resource, :url)
  end

  test "challenge fails closed on an unauthorized host" do
    error = assert_raises(KeyError) do
      with_app_host("attacker.example.test") { @order.challenge }
    end
    assert_match(/unauthorized APP_HOST/i, error.message)
    assert_raises(KeyError) do
      with_app_host("https://lesvendredis.casa") { @order.challenge }
    end
  end

  private

  def with_app_host(host)
    original_fetch = AppConfig.method(:fetch)
    AppConfig.define_singleton_method(:fetch) { |_env_key, *_credential_path, **_kwargs| host }
    yield
  ensure
    AppConfig.define_singleton_method(:fetch, original_fetch)
  end
end
