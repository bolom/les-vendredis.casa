Sentry.init do |config|
  config.dsn = Rails.application.credentials.dig(:glitchtip, :dsn)
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
end
