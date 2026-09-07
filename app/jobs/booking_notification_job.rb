class BookingNotificationJob < ApplicationJob
  def perform(id = nil)
    unless id
      BookingNotification.where(sent_at: nil).where("next_attempt_at IS NULL OR next_attempt_at <= ?", Time.current).where("attempts < 5").find_each(&:enqueue_delivery)
      return
    end

    notification = BookingNotification.find_by(id: id)
    return unless notification
    notification.with_lock do
      return if notification.sent_at || notification.attempts >= 5
      return if notification.next_attempt_at && notification.next_attempt_at > Time.current
      # Resend remembers idempotency keys for 24 hours. Ambiguous older sends
      # require reconciliation instead of a new automatic delivery.
      if notification.first_attempt_at && notification.first_attempt_at < 23.hours.ago
        notification.update!(attempts: 5, last_error: "reconciliation_required")
        return
      end
      notification.update!(first_attempt_at: notification.first_attempt_at || Time.current, attempts: notification.attempts + 1, next_attempt_at: 2.minutes.from_now)
    end
    # Commit the first attempt and lease before sending: a crash must not reset
    # the provider's 24-hour deduplication window or permit simultaneous sends.
    begin
      provider_id = delivery.call(notification)
      notification.update!(sent_at: Time.current, provider_id: provider_id, last_error: nil)
    rescue BookingNotifications::Delivery::PermanentFailure
      notification.update!(attempts: 5, last_error: "delivery_configuration_or_payload")
    rescue StandardError => error
      notification.update!(last_error: error.class.name, next_attempt_at: (2 ** notification.attempts).minutes.from_now)
    end
  end

  private

  def delivery
    BookingNotifications::Delivery.new
  end
end
