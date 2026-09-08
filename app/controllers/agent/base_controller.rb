# frozen_string_literal: true

module Agent
  # Machine API surface. Deliberately NOT under ApplicationController: no
  # cookie session, no browser helpers, no CSRF (Bearer-token auth, no
  # cookies are ever read). Authentication is a dedicated, revocable
  # AgentToken passed as a Bearer header. Read endpoints are permissive
  # (any active token); every mutation requires its explicit capability on
  # the token, is audited and is idempotent when replayable.
  class BaseController < ActionController::Base
    skip_forgery_protection

    before_action :authenticate_agent_token!

    rescue_from Agent::Errors::UnauthorizedError, with: :render_unauthorized
    rescue_from Agent::Errors::ForbiddenError, with: :render_forbidden
    rescue_from Agent::Errors::NotFoundError, with: :render_not_found
    rescue_from Agent::Errors::UnprocessableError, with: :render_unprocessable
    # A missing record is a clean JSON 404, not a crash. This handler must
    # render directly: an exception raised inside a rescue_from handler is
    # not caught by the other handlers.
    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: "not_found" }, status: :not_found
    end

    protected

    attr_reader :current_agent_token

    def authenticate_agent_token!
      header = request.headers["Authorization"].to_s
      plaintext = header.delete_prefix("Bearer ").strip
      token = AgentToken.authenticate(plaintext)
      raise Agent::Errors::UnauthorizedError if token.nil?

      @current_agent_token = token
    end

    def require_agent_permission!(permission)
      raise Agent::Errors::ForbiddenError, permission unless current_agent_token.can?(permission)
    end

    # Every mutating action goes through here: explicit capability check,
    # idempotency replay, audited execution, stable JSON response shape.
    # `target` is the record the action acts on (for the audit log even when
    # the action fails). The yielded block returns the JSON payload.
    def run_agent_action!(permission:, action:, target: nil)
      require_agent_permission!(permission)

      key = request.headers["Idempotency-Key"].presence
      claimed = key ? AgentIdempotencyKey.claim!(agent_token: current_agent_token, key: key, action: action)[1] : nil

      if claimed&.replayable?
        status, body = claimed.replay
        return render json: body, status: status
      end

      begin
        payload = yield
        log_agent_action!(action, target: target, result: "ok", request_key: key)
        respond_with_idempotency!(claimed, status: 200, payload: { action: action, status: "ok", result: payload })
      rescue Agent::Errors::UnprocessableError, AvailabilityBlocks::Error, BookingInquiries::Error, StayRules::Error => error
        log_agent_action!(action, target: target, result: "error", details: { error: error.message }, request_key: key)
        respond_with_idempotency!(claimed, status: 422, payload: { action: action, status: "error", error: error.message })
      rescue StandardError
        # Unexpected crash: release the claimed key so a retry can execute.
        claimed&.destroy if claimed&.running?
        raise
      end
    end

    def log_agent_action!(action, target: nil, result: "ok", details: {}, request_key: nil)
      AgentActionLog.record!(
        agent_token: current_agent_token,
        action: action,
        target: target,
        result: result,
        details: details,
        request_key: request_key
      )
    end

    private

    def respond_with_idempotency!(claimed, status:, payload:)
      claimed&.store!(status: status, body: payload)
      render json: payload, status: status
    end

    def render_unauthorized(_error)
      render json: { error: "unauthorized" }, status: :unauthorized
    end

    def render_forbidden(error)
      render json: { error: "forbidden", missing_permission: error.permission }, status: :forbidden
    end

    def render_not_found(error)
      render json: { error: "not_found", message: error.message }, status: :not_found
    end

    def render_unprocessable(error)
      render json: { error: "unprocessable", message: error.message }, status: :unprocessable_entity
    end
  end
end
