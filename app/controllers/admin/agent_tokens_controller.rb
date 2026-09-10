# frozen_string_literal: true

module Admin
  class AgentTokensController < BaseController
    before_action :require_technical_access

    def index
      load_tokens
    end

    def create
      permissions = AgentToken::READ_PERMISSIONS + permitted_permissions
      @created_token, @plaintext_token = AgentToken.generate!(name: token_params[:name], permissions: permissions.uniq)
      response.headers["Cache-Control"] = "no-store"
      load_tokens
      render :index, status: :created
    rescue ActiveRecord::RecordInvalid => error
      @agent_token = error.record
      load_tokens
      render :index, status: :unprocessable_entity
    end

    def revoke
      token = AgentToken.find(params[:id])
      token.revoke! unless token.revoked_at?

      redirect_to admin_agent_tokens_path, notice: "Token « #{token.name} » révoqué."
    end

    private

    def load_tokens
      @agent_token ||= AgentToken.new
      @agent_tokens ||= AgentToken.order(created_at: :desc)
    end

    def token_params
      params.expect(agent_token: [ :name, permissions: [] ])
    end

    def permitted_permissions
      Array(token_params[:permissions]) & AgentToken::MUTATION_PERMISSIONS
    end
  end
end
