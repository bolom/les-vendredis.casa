# frozen_string_literal: true

# Stores the JSON response of the first mutation executed under a given key
# so replaying the same request returns the stored answer instead of doing
# the work twice. Scoped per agent token; no expiry (cleanup can be added
# later if the table grows, responses are tiny and rarely replayed).
#
# A claimed key starts in the "running" state: the stored response exists
# only once the action has actually completed. Sequential retries replay
# the stored response; concurrent requests sharing a key may both execute
# (the underlying business locks keep that safe) and the last stored
# response wins.
class AgentIdempotencyKey < ApplicationRecord
  RUNNING_STATUS = "running"

  belongs_to :agent_token

  validates :key, presence: true
  validates :action, presence: true
  validates :result_status, presence: true

  # Atomically claims the key for this token/action pair. Returns
  # [created?, existing_record]. A fresh claim is "running" until the
  # action stores its response; a record with a stored response replays.
  def self.claim!(agent_token:, key:, action:)
    record = find_by(agent_token: agent_token, key: key, action: action)
    return [ false, record ] if record

    fresh = find_or_create_by!(agent_token: agent_token, key: key, action: action) do |candidate|
      candidate.result_status = RUNNING_STATUS
      candidate.result_body = {}
    end
    [ fresh.previously_new_record?, fresh ]
  rescue ActiveRecord::RecordNotUnique
    [ false, find_by!(agent_token: agent_token, key: key, action: action) ]
  end

  # Only a completed response is replayable: a "running" claim must never
  # be replayed as if it were a stored answer.
  def replayable?
    result_status.present? && result_status != RUNNING_STATUS
  end

  def running?
    result_status == RUNNING_STATUS
  end

  def store!(status:, body:)
    update!(result_status: Rack::Utils.status_code(status).to_s, result_body: body)
    self
  end

  def replay
    [ result_status.to_i, result_body ]
  end
end
