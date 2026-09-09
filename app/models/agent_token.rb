# frozen_string_literal: true

# Dedicated machine credential, fully separate from the human web session:
# no cookie, no session record. The raw token is shown once at creation and
# only its SHA-256 digest is stored. Permission model: read is granted by
# default; every mutating capability must be listed explicitly and is
# revocable per token by updating `permissions` or `active`.
class AgentToken < ApplicationRecord
  READ_PERMISSIONS = %w[read].freeze

  MUTATION_PERMISSIONS = %w[
    block_dates
    cancel_block
    record_booking
    accept_booking
    decline_booking
    cancel_booking
    update_stay_rules
    sync_calendars
  ].freeze

  ALL_PERMISSIONS = (READ_PERMISSIONS + MUTATION_PERMISSIONS).freeze

  has_many :agent_action_logs, dependent: :destroy
  has_many :agent_idempotency_keys, dependent: :destroy

  validates :name, presence: true
  validates :token_digest, presence: true, uniqueness: true
  validates :token_prefix, presence: true
  validates :permissions, inclusion: { in: ALL_PERMISSIONS }, unless: -> { permissions.blank? }
  validate :permissions_cannot_be_partial_read, if: -> { permissions.present? }

  scope :active, -> { where(active: true, revoked_at: nil) }

  # Generates a new token and returns [record, plaintext]. The plaintext is
  # never persisted and cannot be recovered: rotate by creating a new token
  # and revoking this one.
  def self.generate!(name:, permissions: READ_PERMISSIONS)
    plaintext = "lv_agent_#{SecureRandom.hex(24)}"
    record = create!(
      name: name,
      token_digest: OpenSSL::HMAC.hexdigest("SHA256", digest_key, plaintext),
      token_prefix: plaintext.first(12),
      permissions: permissions
    )
    [ record, plaintext ]
  end

  def self.authenticate(plaintext)
    return nil if plaintext.blank?

    token = find_by(token_digest: OpenSSL::HMAC.hexdigest("SHA256", digest_key, plaintext))
    return nil unless token&.active? && token.revoked_at.nil?

    token.update_column(:last_used_at, Time.current) # rubocop:disable Rails/SkipsModelValidations
    token
  end

  def can?(permission)
    return true if permission == "read"

    permissions.include?(permission)
  end

  def revoke!
    update!(active: false, revoked_at: Time.current)
  end

  # Deliberately limited so a leaked agent token cannot list other tokens or
  # reconstruct secret material.
  def self.digest_key
    Rails.application.secret_key_base
  end

  private

  # Read is always on; the permissions array carries mutation capabilities.
  def permissions_cannot_be_partial_read
    return if permissions.include?("read")

    errors.add(:permissions, "must always include the read permission")
  end
end
