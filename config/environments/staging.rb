require_relative "production"

Rails.application.configure do
  # Staging inherits the production configuration and adapts it to its own hostname.
  config.hosts << "staging.lesvendredis.casa"
  config.host_authorization = {
    exclude: ->(request) { request.path == "/up" }
  }

  config.action_mailer.default_url_options = {
    host: AppConfig.fetch("APP_HOST", :app, :host, default: "staging.lesvendredis.casa")
  }
end
