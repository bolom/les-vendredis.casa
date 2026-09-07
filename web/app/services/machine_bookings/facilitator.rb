require "net/http"
require "json"

module MachineBookings
  class Facilitator
    class Unavailable < StandardError; end

    def call(action, payload, requirements)
      raise ArgumentError unless %w[verify settle].include?(action)
      PaymentConfiguration.validate!
      uri = URI.parse("#{PaymentConfiguration.fetch(:facilitator_url).delete_suffix('/')}/#{action}")
      request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
      token = PaymentConfiguration.fetch(:facilitator_token)
      request["Authorization"] = "Bearer #{token}" if token.present?
      request.body = JSON.generate(x402Version: 2, paymentPayload: payload, paymentRequirements: requirements)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 20, write_timeout: 10) { |http| http.request(request) }
      raise Unavailable unless response.is_a?(Net::HTTPSuccess)
      result = JSON.parse(response.body)
      raise Unavailable unless result.is_a?(Hash)
      result
    rescue Timeout::Error, IOError, SystemCallError, SocketError, OpenSSL::SSL::SSLError, JSON::ParserError
      raise Unavailable
    end
  end
end
