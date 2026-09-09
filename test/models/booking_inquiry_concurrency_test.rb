require "test_helper"

class BookingInquiryConcurrencyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  teardown do
    PaymentOrder.delete_all
    BookingNotification.delete_all
    BookingInquiry.delete_all
    AvailabilityBlock.delete_all
    StayRule.delete_all
  end

  test "two concurrent accepts of the same inquiry produce exactly one block" do
    inquiry = BookingInquiry.create!(
      check_in: Date.new(2026, 11, 10),
      check_out: Date.new(2026, 11, 12),
      adults: 2,
      children: 0,
      guest_name: "Concurrent Guest",
      email: "concurrent@example.com",
      locale: "en"
    )

    threads = 2.times.map do
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          outcome = nil
          5.times do
            begin
              outcome = inquiry.reload.accept!
              break
            rescue ActiveRecord::RecordNotFound
              sleep 0.05
            rescue BookingInquiry::DatesUnavailable
              outcome = false
              break
            end
          end
          outcome
        end
      end
    end
    outcomes = threads.map(&:value).compact

    assert_equal 1, outcomes.select { |outcome| outcome != false }.size
    assert_not outcomes.include?(nil), "both threads must complete"
    assert_equal 1, AvailabilityBlock.count
    assert_equal "accepted", inquiry.reload.status
    assert_not_nil inquiry.accepted_at
  end

  test "concurrent accepts of overlapping inquiries are refused by the database constraint" do
    first = BookingInquiry.create!(
      check_in: Date.new(2026, 11, 10),
      check_out: Date.new(2026, 11, 12),
      adults: 2,
      children: 0,
      guest_name: "First Guest",
      email: "first@example.com",
      locale: "en"
    )
    second = BookingInquiry.create!(
      check_in: Date.new(2026, 11, 11),
      check_out: Date.new(2026, 11, 13),
      adults: 2,
      children: 0,
      guest_name: "Second Guest",
      email: "second@example.com",
      locale: "en"
    )

    threads = [ first, second ].map do |inquiry|
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          begin
            5.times do
              begin
                inquiry.reload.accept!
                break
              rescue ActiveRecord::RecordNotFound
                sleep 0.05
              end
            end
          rescue BookingInquiry::DatesUnavailable, ActiveRecord::StatementInvalid, ActiveRecord::RecordInvalid
            nil
          end
          inquiry.reload.status
        end
      end
    end
    statuses = threads.map(&:value)

    assert_includes statuses, "accepted"
    assert_equal 1, AvailabilityBlock.where(status: %w[tentative confirmed]).count
  end

  test "cancelling the block cancels the accepted inquiry once and notifies once" do
    freeze_time
    inquiry = BookingInquiry.create!(
      check_in: Date.new(2026, 11, 10),
      check_out: Date.new(2026, 11, 12),
      adults: 2,
      children: 0,
      guest_name: "Cancelled Guest",
      email: "cancelled@example.com",
      locale: "en"
    )
    inquiry.accept!
    assert_equal "accepted", inquiry.status
    block = AvailabilityBlock.find(inquiry.availability_block_id)

    assert_difference -> { BookingNotification.where(event: "guest_cancellation").count }, 1 do
      block.update!(status: "cancelled")
    end

    assert_equal "cancelled", inquiry.reload.status

    assert_no_difference -> { BookingNotification.where(event: "guest_cancellation").count } do
      block.reload.update!(status: "cancelled")
    end
  end

  test "block cancellation is blocked while a payment is settling" do
    inquiry = BookingInquiry.create!(
      check_in: Date.new(2026, 11, 10),
      check_out: Date.new(2026, 11, 12),
      adults: 2,
      children: 0,
      guest_name: "Paid Guest",
      email: "paid@example.com",
      locale: "en"
    )
    inquiry.accept!
    block = AvailabilityBlock.find(inquiry.availability_block_id)
    PaymentOrder.create!(
      availability_block: block,
      public_id: "po_concurrency_test",
      quote: { total_eur: 1.5 },
      requirements: { scheme: "exact", network: "base", asset: "eurc", payTo: "0xabc", amount: "1500000" },
      expires_at: 1.hour.from_now,
      status: "settling"
    )

    assert_raises(ActiveRecord::RecordNotSaved) { block.update!(status: "cancelled") }
    assert_equal "confirmed", block.reload.status
    assert_equal "accepted", inquiry.reload.status
    assert_empty BookingNotification.where(event: "guest_cancellation")
  end

  test "concurrent purchases of overlapping dates charge exactly once" do
    # Route helpers are loaded lazily in test. Initialize them before the two
    # checkout threads both render the owner notification mailer.
    Rails.application.routes.url_helpers.admin_booking_inquiry_url(0, host: "example.test")

    quote = MachineBookings::Quote.build(date: "2026-11-10", nights: 2, adults: 2, children: 0)
    orders = 2.times.map do
      PaymentOrder.create!(quote: quote.as_json, expires_at: 15.minutes.from_now, requirements: {
        scheme: "exact", network: "eip155:8453", amount: "148000000", asset: "0x#{'1' * 40}", payTo: "0x#{'2' * 40}", maxTimeoutSeconds: 900
      })
    end

    threads = orders.map do |order|
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          checkout = MachineBookings::Checkout.new(order, facilitator: FakeCheckoutFacilitator.new)
          begin
            checkout.call(payment_proof(order), { guest_name: "Buyer #{order.public_id}", email: "buyer@example.test", locale: "en", contact_consent: "1" })
            order.reload.status
          rescue MachineBookings::Checkout::Conflict, ActiveRecord::StatementInvalid, ActiveRecord::RecordInvalid
            "conflict"
          end
        end
      end
    end
    outcomes = threads.map(&:value)

    assert_equal 1, outcomes.count("paid")
    assert_equal 1, PaymentOrder.where(status: "paid").count
    assert_equal 1, AvailabilityBlock.where(status: "confirmed").count
    assert_equal 1, BookingInquiry.where(status: "accepted").count
  end

  private

  def payment_proof(order)
    auth = { from: "0x#{'4' * 40}", to: order.requirements["payTo"], value: "148000000", validAfter: (Time.current.to_i - 10).to_s,
      validBefore: order.expires_at.to_i.to_s, nonce: "0x#{Digest::SHA256.hexdigest(order.public_id)}" }
    Base64.strict_encode64(JSON.generate(x402Version: 2, accepted: order.requirements, payload: { signature: "0x#{'5' * 130}", authorization: auth }))
  end

  class FakeCheckoutFacilitator
    def call(action, payload, requirements)
      return { "isValid" => true } if action == "verify"
      { "success" => true, "network" => requirements["network"], "transaction" => "0x#{'a' * 64}" }
    end
  end
end
