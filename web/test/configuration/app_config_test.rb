require "test_helper"

class AppConfigTest < ActiveSupport::TestCase
  FakeCredentials = Data.define(:values) do
    def dig(*path)
      values.dig(*path)
    end
  end

  test "prefers encrypted credentials" do
    with_env("APP_CONFIG_TEST", "from-env") do
      credentials = FakeCredentials.new({ example: "from-credentials" })

      assert_equal "from-credentials", AppConfig.fetch("APP_CONFIG_TEST", :example, credentials: credentials)
    end
  end

  test "falls back to environment during credential migration" do
    with_env("APP_CONFIG_TEST", "from-env") do
      credentials = FakeCredentials.new({ example: nil })

      assert_equal "from-env", AppConfig.fetch("APP_CONFIG_TEST", :example, credentials: credentials)
    end
  end

  test "raises without required configuration" do
    with_env("APP_CONFIG_TEST", nil) do
      credentials = FakeCredentials.new({})

      assert_raises(KeyError) { AppConfig.fetch!("APP_CONFIG_TEST", :example, credentials: credentials) }
    end
  end

  private

  def with_env(key, value)
    previous = ENV[key]
    value.nil? ? ENV.delete(key) : ENV[key] = value
    yield
  ensure
    previous.nil? ? ENV.delete(key) : ENV[key] = previous
  end
end
