# frozen_string_literal: true

# Stores the JSON response of the first mutation executed under a given key
# so replaying the same request returns the stored answer instead of doing
# the work twice. Scoped per agent token; no expiry (cleanup can be added
# later if the table grows, responses are tiny and rarely replayed).
class AgentIdempotencyKey < ApplicationRecord
  belongs_to :agent_token

  validates :key, presence: true
  validates :action, presence: true
  validates :result_status, presence: true

  # Atomically claims the key for this token/action pair. Returns
  # [created?, existing_record]. When a concurrent request claims the key
  # first, the loser reads the winner's stored response and replays it.
  def self.claim!(agent_token:, key:, action:)
    record = find_by(agent_token: agent_token, key: key, action: action)
    return [ false, record ] if record

    fresh = create_with(action: action).find_or_create_by!(agent_token: agent_token, key: key)
    [ fresh.previously_new_record?, fresh ]
  rescue ActiveRecord::RecordNotUnique
    [ false, find_by!(agent_token: agent_token, key: key, action: action) ]
  end

  def store!(status:, body:)
    update!(result_status: status.to_s, result_body: body)
    self
  end

  def replay
    [ result_status.to_i, result_body ]
  end
end
