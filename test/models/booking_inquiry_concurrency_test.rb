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
          rescue ActiveRecord::StatementInvalid, ActiveRecord::RecordInvalid
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
end
