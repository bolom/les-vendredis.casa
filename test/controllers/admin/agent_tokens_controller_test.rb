require "test_helper"

module Admin
  class AgentTokensControllerTest < ActionDispatch::IntegrationTest
    test "requires authentication" do
      get admin_agent_tokens_path

      assert_redirected_to new_session_path
    end

    test "redirects accounts without technical access for every action" do
      token, = AgentToken.generate!(name: "restricted")
      sign_in_as users(:two)

      get admin_agent_tokens_path
      assert_redirected_to admin_root_path

      assert_no_difference "AgentToken.count" do
        post admin_agent_tokens_path, params: { agent_token: { name: "forbidden", permissions: [ "block_dates" ] } }
      end
      assert_redirected_to admin_root_path

      patch revoke_admin_agent_token_path(token)
      assert_redirected_to admin_root_path
      assert token.reload.active?
    end

    test "technical account can list tokens without exposing their digest" do
      token, = AgentToken.generate!(name: "nox", permissions: %w[read block_dates])
      sign_in_as users(:one)

      get admin_agent_tokens_path

      assert_response :success
      assert_select "td", text: /nox/
      assert_select "td", text: /Block dates/
      assert_includes response.body, token.token_prefix
      assert_not_includes response.body, token.token_digest
    end

    test "technical account creates a token whose plaintext is shown only in that response" do
      sign_in_as users(:one)

      assert_difference "AgentToken.count", 1 do
        post admin_agent_tokens_path, params: {
          agent_token: { name: "assistant", permissions: [ "block_dates", "unknown" ] }
        }
      end

      assert_response :created
      assert_equal "no-store", response.headers["Cache-Control"]
      token = AgentToken.order(:id).last
      plaintext = response.body[/lv_agent_[0-9a-f]{48}/]
      assert plaintext.present?
      assert_equal %w[read block_dates], token.permissions
      assert_not_equal plaintext, token.token_digest
      assert_not_includes token.attributes.values, plaintext

      get admin_agent_tokens_path
      assert_response :success
      assert_not_includes response.body, plaintext
    end

    test "invalid creation does not create or reveal a token" do
      sign_in_as users(:one)

      assert_no_difference "AgentToken.count" do
        post admin_agent_tokens_path, params: { agent_token: { name: "", permissions: [] } }
      end

      assert_response :unprocessable_entity
      assert_no_match(/lv_agent_[0-9a-f]{48}/, response.body)
    end

    test "revocation immediately rejects the bearer token" do
      token, plaintext = AgentToken.generate!(name: "to revoke")
      sign_in_as users(:one)

      patch revoke_admin_agent_token_path(token)

      assert_redirected_to admin_agent_tokens_path
      assert_not token.reload.active?
      assert token.revoked_at?

      get "/agent/house", headers: { "Authorization" => "Bearer #{plaintext}" }
      assert_response :unauthorized
    end
  end
end
