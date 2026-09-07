require "net/http"

module BookingNotifications
  class Delivery
    class PermanentFailure < StandardError; end
    class TemporaryFailure < StandardError; end

    def call(notification)
      payload = notification.payload
      unless Rails.env.production?
        message = Mail.new do
          self.charset = "UTF-8"
          from payload["from"]
          to payload["to"]
          subject payload["subject"]
          body payload["text"]
        end
        method = ActionMailer::Base.delivery_method
        message.delivery_method(method, ActionMailer::Base.public_send("#{method}_settings"))
        message.deliver!
        return "local-#{notification.id}"
      end
      request = Net::HTTP::Post.new("/emails", "Content-Type" => "application/json")
      request["Authorization"] = "Bearer #{AppConfig.fetch('RESEND_API_KEY', :resend, :api_key)}"
      request["Idempotency-Key"] = "booking-#{notification.event}/#{notification.booking_inquiry_id}"
      request.body = JSON.generate(payload)
      response = Net::HTTP.start("api.resend.com", 443, use_ssl: true, open_timeout: 5, read_timeout: 15, write_timeout: 10) { |http| http.request(request) }
      if response.is_a?(Net::HTTPSuccess)
        id = JSON.parse(response.body)["id"]
        raise TemporaryFailure if id.blank?
        return id
      end
      raise TemporaryFailure if response.code.to_i >= 500 || response.code == "429"
      raise PermanentFailure
    end
  end
end
