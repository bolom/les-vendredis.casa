class BookingNotification < ApplicationRecord
  belongs_to :booking_inquiry
  EVENTS = %w[owner_notification guest_acknowledgement guest_acceptance guest_decline guest_cancellation].freeze
  validates :event, inclusion: { in: EVENTS }
  attr_readonly :payload, :event, :booking_inquiry_id
  after_create_commit :enqueue_delivery

  def self.record!(inquiry, event)
    raise ArgumentError unless EVENTS.include?(event)
    message = BookingInquiryMailer.with(booking_inquiry: inquiry).public_send(event).message
    create!(booking_inquiry: inquiry, event: event, payload: {
      from: message[:from].to_s, to: message.to, subject: message.subject, text: message.body.decoded
    })
  end

  def enqueue_delivery
    BookingNotificationJob.perform_later(id)
  rescue StandardError => error
    # The recurring sweeper recovers committed notifications if the queue is down.
    Rails.logger.error("Booking notification enqueue failed: #{error.class}")
  end
end
