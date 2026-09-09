# frozen_string_literal: true

# Shared business actions on AvailabilityBlock, used by both the human admin
# HTML controller and the agent API. Keeps the existing model guards intact
# (overlap exclusion, payment reconciliation, managed stays) — this layer
# adds no new rule, it only routes input the same way for both surfaces.
module AvailabilityBlocks
  class Error < StandardError; end

  # Anaïs (and agents) only ever block dates: dates + optional label. Kind,
  # source and status are pinned (manual_closure / manual / confirmed) — no
  # technical status is ever caller-provided.
  module_function

  def create(starts_on:, ends_on:, summary: nil)
    block = AvailabilityBlock.new(
      starts_on: starts_on,
      ends_on: ends_on,
      summary: summary.presence,
      kind: "manual_closure",
      source: "manual",
      status: "confirmed"
    )
    block.save!
    block
  rescue ActiveRecord::RecordInvalid => error
    raise Error, error.record.errors.full_messages.to_sentence
  end

  # Cancellation is the only allowed end-of-life here: blocks are kept for
  # the audit trail, never deleted. The model still refuses to cancel a
  # stay managed by an unresolved payment — this layer surfaces that as a
  # domain error instead of a validation crash.
  def cancel(block)
    block.update!(status: "cancelled")
    block
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => error
    raise Error, error.message.presence || "this block cannot be cancelled"
  end
end
