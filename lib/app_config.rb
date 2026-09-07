module AppConfig
  module_function

  def fetch(env_key, *credential_path, default: nil, credentials: Rails.application.credentials)
    credentials.dig(*credential_path).presence || ENV[env_key].presence || default
  end

  def fetch!(env_key, *credential_path, credentials: Rails.application.credentials)
    fetch(env_key, *credential_path, credentials: credentials) ||
      raise(KeyError, "Missing application configuration: #{env_key}")
  end
end
