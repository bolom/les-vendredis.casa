namespace :production do
  desc "Check production boot-critical configuration without printing secret values"
  task check: :environment do
    required_credentials = {
      "database.url" => Rails.application.credentials.dig(:database, :url),
      "resend.api_key" => Rails.application.credentials.dig(:resend, :api_key),
      "calendars.airbnb_ical_url" => Rails.application.credentials.dig(:calendars, :airbnb_ical_url),
      "calendars.booking_ical_url" => Rails.application.credentials.dig(:calendars, :booking_ical_url),
      "secret_key_base" => Rails.application.credentials.secret_key_base
    }

    missing = required_credentials.filter_map do |name, value|
      name if value.blank? || value.to_s.match?(/\A(?:REPLACE_ME|CHANGE_ME)\z/i)
    end
    abort "Missing Rails credentials: #{missing.join(', ')}" if missing.any?

    checks = {
      "mailer delivery" => ActionMailer::Base.delivery_method,
      "active job adapter" => Rails.application.config.active_job.queue_adapter,
      "app host" => Rails.application.config.action_mailer.default_url_options[:host]
    }

    checks.each { |label, value| puts "#{label}: #{value}" }
    puts "production environment check passed"
  end
end
