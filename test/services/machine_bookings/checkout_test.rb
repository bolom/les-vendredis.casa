require "test_helper"

class MachineBookingsCheckoutTest < ActiveSupport::TestCase
  class FakeFacilitator
    attr_reader :calls
    attr_accessor :valid, :failure

    def initialize
      @calls = []
      @valid = true
    end

    def call(action, payload, requirements)
      @calls << action
      return { "isValid" => valid } if action == "verify"
      raise MachineBookings::Facilitator::Unavailable if failure
      { "success" => true, "network" => requirements["network"], "transaction" => "0x#{'a' * 64}" }
    end
  end

  setup do
    @facilitator = FakeFacilitator.new
    quote = MachineBookings::Quote.build(date: "2026-11-30", nights: 2, adults: 2, children: 0)
    @order = PaymentOrder.create!(quote: quote.as_json, expires_at: 15.minutes.from_now, requirements: {
      scheme: "exact", network: "eip155:8453", amount: "148000000", asset: "0x#{'1' * 40}", payTo: "0x#{'2' * 40}", maxTimeoutSeconds: 900
    })
    @guest = { guest_name: "Payment test", email: "guest@example.test", locale: "fr", contact_consent: "1" }
  end

  test "verified settlement confirms exactly once and keeps stored price" do
    proof = payment
    result = checkout.call(proof, @guest)
    assert_equal "paid", result.status
    assert result.booking_inquiry.status_accepted?
    assert_equal "confirmed", result.availability_block.status
    assert_equal "148000000", result.requirements["amount"]
    assert_no_difference [ "BookingInquiry.count", "AvailabilityBlock.count" ] do
      assert_equal "paid", checkout.call(proof, @guest).status
    end
    assert_equal %w[verify settle], @facilitator.calls
  end

  test "invalid verification creates no reservation" do
    @facilitator.valid = false
    assert_no_difference [ "BookingInquiry.count", "AvailabilityBlock.count" ] do
      assert_raises(MachineBookings::Checkout::Invalid) { checkout.call(payment, @guest) }
    end
    assert_equal [ "verify" ], @facilitator.calls
  end

  test "settlement timeout retains hold and does not resubmit payment" do
    @facilitator.failure = true
    proof = payment
    assert_raises(MachineBookings::Checkout::Pending) { checkout.call(proof, @guest) }
    assert_equal "review", @order.reload.status
    assert_equal "tentative", @order.availability_block.status
    assert_raises(MachineBookings::Checkout::Pending) { checkout.call(proof, @guest) }
    assert_equal %w[verify settle], @facilitator.calls
  end

  test "expired or changed authorization is rejected before facilitator" do
    [ payment(value: "1"), payment(to: "0x#{'3' * 40}"), payment(nonce: "0x#{'b' * 64}"), payment(validBefore: Time.current.to_i.to_s) ].each do |proof|
      assert_raises(MachineBookings::Checkout::Invalid) { checkout.call(proof, @guest) }
    end
    assert_empty @facilitator.calls
  end

  test "dates taken after quote are never charged" do
    AvailabilityBlock.create!(starts_on: "2026-11-30", ends_on: "2026-12-02", kind: "manual_closure", source: "manual", status: "confirmed")
    assert_raises(MachineBookings::Checkout::Conflict) { checkout.call(payment, @guest) }
    assert_equal [ "verify" ], @facilitator.calls
    assert_nil @order.reload.booking_inquiry
  end

  test "another quote cannot reuse a signed authorization" do
    another = PaymentOrder.create!(quote: @order.quote, requirements: @order.requirements, expires_at: @order.expires_at)
    assert_raises(MachineBookings::Checkout::Invalid) do
      MachineBookings::Checkout.new(another, facilitator: @facilitator).call(payment, @guest)
    end
    assert_empty @facilitator.calls
  end

  test "verified manual refund releases dates and cannot charge again" do
    proof = payment
    checkout.call(proof, @guest)
    @order.reconcile!(outcome: "refunded", evidence: "Refund verified externally: transaction example", actor: users(:one))
    assert_equal "refunded", @order.reload.status
    assert_equal "cancelled", @order.availability_block.status
    assert @order.booking_inquiry.status_cancelled?
    assert_equal users(:one).id, @order.reconciliation["actor_id"]
    assert_raises(MachineBookings::Checkout::Conflict) { checkout.call(proof, @guest) }
    assert_equal %w[verify settle], @facilitator.calls
  end

  test "a paid order cannot be reconciled as no transfer" do
    checkout.call(payment, @guest)
    assert_raises(ArgumentError) do
      @order.reconcile!(outcome: "no_transfer", evidence: "No transfer found in provider dashboard", actor: users(:one))
    end
    assert_equal "paid", @order.reload.status
  end

  private

  def checkout
    MachineBookings::Checkout.new(@order, facilitator: @facilitator)
  end

  def payment(**changes)
    auth = { from: "0x#{'4' * 40}", to: @order.requirements["payTo"], value: "148000000", validAfter: (Time.current.to_i - 10).to_s,
      validBefore: @order.expires_at.to_i.to_s, nonce: "0x#{Digest::SHA256.hexdigest(@order.public_id)}" }.merge(changes)
    Base64.strict_encode64(JSON.generate(x402Version: 2, accepted: @order.requirements, payload: { signature: "0x#{'5' * 130}", authorization: auth }))
  end
end
