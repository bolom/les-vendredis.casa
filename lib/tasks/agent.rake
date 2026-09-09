# frozen_string_literal: true

# Machine credentials for the agent API. The plaintext is shown once at
# creation and never stored (only its digest is): rotate by creating a new
# token and revoking the old one, never by looking the old one up.
namespace :agent do
  namespace :tokens do
    desc "Create an agent API token. NAME=nox PERMISSIONS=read,record_booking,accept_booking"
    task create: :environment do
      name = ENV["NAME"].presence
      abort("NAME is required, e.g. NAME=nox") if name.nil?

      permissions = (ENV["PERMISSIONS"].presence || "read").split(",").map(&:strip).reject(&:empty?)
      unknown = permissions - AgentToken::ALL_PERMISSIONS
      if unknown.any?
        abort("unknown permissions: #{unknown.join(', ')} (allowed: #{AgentToken::ALL_PERMISSIONS.join(', ')})")
      end

      record, plaintext = AgentToken.generate!(name: name, permissions: permissions)

      puts "id          #{record.id}"
      puts "name        #{record.name}"
      puts "permissions #{record.permissions.join(', ')}"
      puts "token       #{plaintext}"
      puts
      puts "Copy it now: the plaintext cannot be recovered."
    end

    desc "List agent tokens (never prints secrets)"
    task list: :environment do
      tokens = AgentToken.order(:id)
      if tokens.none?
        puts "no agent tokens"
        next
      end

      tokens.each do |token|
        state = token.active? && token.revoked_at.nil? ? "active" : "revoked"
        puts "#{token.id}\t#{token.name}\t#{state}\t#{token.permissions.join(',')}\tlast_used=#{token.last_used_at&.iso8601 || '-'}"
      end
    end
  end
end
