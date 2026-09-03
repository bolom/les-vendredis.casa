namespace :production do
  desc "Check production/staging boot-critical environment without printing secret values"
  task check: :environment do
    required = %w[
      APP_HOST
      DATABASE_URL
      RAILS_MASTER_KEY
      RESEND_API_KEY
      SECRET_KEY_BASE
    ]

    missing = required.select { |key| ENV[key].blank? }
    abort "Missing required environment: #{missing.join(', ')}" if missing.any?

    checks = {
      "mailer delivery" => ActionMailer::Base.delivery_method,
      "active job adapter" => Rails.application.config.active_job.queue_adapter,
      "app host" => Rails.application.config.action_mailer.default_url_options[:host]
    }

    checks.each { |label, value| puts "#{label}: #{value}" }
    puts "production environment check passed"
  end
end
