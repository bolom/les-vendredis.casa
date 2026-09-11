require "test_helper"

class BookingNotificationJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  setup do
    @inquiry = BookingInquiry.create!(check_in: "2026-11-01", check_out: "2026-11-03", guest_name: "Test", email: "local@example.test", locale: "fr")
    @notification = BookingNotification.find_by!(booking_inquiry: @inquiry, event: "guest_acknowledgement")
  end

  test "payload captures both text and html bodies (multipart regression)" do
    payload = @notification.reload.payload
    assert payload["text"].present?, "text body must not be empty"
    assert payload["html"].present?, "html body must not be empty"
  end

  test "records notification atomically and sends only once" do    assert_equal 2, BookingNotification.where(booking_inquiry: @inquiry).count
    assert_difference "ActionMailer::Base.deliveries.size", 1 do
      BookingNotificationJob.perform_now(@notification.id)
      assert @notification.reload.sent_at, @notification.last_error
      BookingNotificationJob.perform_now(@notification.id)
    end
    assert @notification.reload.sent_at, @notification.last_error
  end

  test "temporary failure stays recoverable with immutable payload" do
    payload = @notification.payload
    delivery = Object.new
    def delivery.call(*)
      raise BookingNotifications::Delivery::TemporaryFailure
    end
    job = BookingNotificationJob.new
    job.define_singleton_method(:delivery) { delivery }
    job.perform(@notification.id)
    assert_nil @notification.reload.sent_at
    assert_equal 1, @notification.attempts
    assert @notification.next_attempt_at > Time.current
    assert_equal payload, @notification.payload
    travel 3.minutes
    BookingNotificationJob.perform_now(@notification.id)
    assert @notification.reload.sent_at
  end

  test "ambiguous delivery older than idempotency window is not resent" do
    @notification.update!(first_attempt_at: 24.hours.ago)
    assert_no_difference "ActionMailer::Base.deliveries.size" do
      BookingNotificationJob.perform_now(@notification.id)
    end
    assert_equal "reconciliation_required", @notification.reload.last_error
  end

  test "sweeper recovers a notification when queue submission failed" do
    assert_enqueued_with(job: BookingNotificationJob, args: [ @notification.id ]) do
      BookingNotificationJob.perform_now
    end
  end
end
