Sentry.init do |config|
  config.dsn = Rails.application.credentials.dig(:glitchtip, :dsn)
  config.enabled_environments = %w[production]
  config.release = ENV["KAMAL_VERSION"].presence
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
end
