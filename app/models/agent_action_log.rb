# frozen_string_literal: true

# Append-only audit trail for every authenticated agent mutation. It records
# who (token), what (action), when (created_at), on what (target) and with
# which result — enough to reconstruct an agent's history without touching
# the human admin logs.
class AgentActionLog < ApplicationRecord
  RESULTS = %w[ok error].freeze

  belongs_to :agent_token

  validates :action, presence: true
  validates :result, inclusion: { in: RESULTS }

  def self.record!(agent_token:, action:, target: nil, result: "ok", details: {}, request_key: nil)
    create!(
      agent_token: agent_token,
      action: action,
      target_type: target&.class&.name,
      target_id: target&.id,
      result: result,
      details: details.deep_stringify_keys,
      request_key: request_key
    )
  end
end
