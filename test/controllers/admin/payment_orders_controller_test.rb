require "test_helper"

module Admin
  class PaymentOrdersControllerTest < ActionDispatch::IntegrationTest
    setup do
      @order = PaymentOrder.create!(
        public_id: "0f0e0d0c-aaaa-bbbb-cccc-444455556666",
        quote: { totalPrice: "148" }.as_json,
        requirements: { scheme: "exact", network: "eip155:8453", amount: "148" }.as_json,
        expires_at: 15.minutes.from_now,
        status: "review"
      )
    end

    test "redirects accounts without technical access" do
      sign_in_as users(:two)

      get admin_payment_orders_path

      assert_redirected_to admin_root_path
      assert_equal "Section technique réservée aux comptes autorisés.", flash[:alert]
    end

    test "requires authentication" do
      get admin_payment_orders_path

      assert_redirected_to new_session_path
    end

    test "admin can list payment orders and filter by status" do
      sign_in_as users(:one)
      PaymentOrder.create!(
        public_id: "0f0e0d0c-aaaa-bbbb-cccc-444455557777",
        quote: { totalPrice: "90" }.as_json,
        requirements: { scheme: "exact", network: "eip155:8453", amount: "90" }.as_json,
        expires_at: 15.minutes.from_now,
        status: "paid"
      )

      get admin_payment_orders_path
      assert_response :success
      assert_select "td", text: @order.public_id

      get admin_payment_orders_path, params: { status: "paid" }
      assert_select "td", text: @order.public_id, count: 0

      get admin_payment_orders_path, params: { status: "pending" }
      assert_select "td", text: @order.public_id
    end

    test "admin can inspect a payment order without raw technical dumps" do
      sign_in_as users(:one)

      get admin_payment_order_path(@order)

      assert_response :success
      assert_select "h1", /#{Regexp.escape(@order.public_id)}/
      assert_select "dd", text: "À vérifier"
      assert_select ".admin-details summary", text: /Détails techniques/
    end

    test "reconciliation form is offered for orders awaiting reconciliation" do
      sign_in_as users(:one)

      get admin_payment_order_path(@order)

      assert_select "form[action='#{admin_payment_order_path(@order)}']"
    end

    test "admin can record a verified reconciliation" do
      sign_in_as users(:one)
      inquiry = BookingInquiry.create!(
        check_in: Date.new(2026, 10, 1),
        check_out: Date.new(2026, 10, 3),
        adults: 2,
        children: 0,
        guest_name: "Guest",
        email: "guest@example.com",
        locale: "en"
      )
      block = AvailabilityBlock.create!(
        starts_on: Date.new(2026, 10, 1),
        ends_on: Date.new(2026, 10, 3),
        kind: "direct_stay",
        source: "direct",
        status: "tentative"
      )
      inquiry.update!(availability_block: block)
      @order.update!(booking_inquiry: inquiry, availability_block: block, updated_at: 10.minutes.ago)

      patch admin_payment_order_path(@order), params: {
        outcome: "confirmed",
        evidence: "Vérifié sur la blockchain, transaction 0xabc123",
        review_confirmed: "1"
      }

      assert_redirected_to admin_payment_order_path(@order)
      assert_equal "paid", @order.reload.status
      assert_equal "confirmed", @order.reconciliation["outcome"]
    end

    test "reconciliation is refused without explicit confirmation" do
      sign_in_as users(:one)
      @order.update!(updated_at: 10.minutes.ago)

      patch admin_payment_order_path(@order), params: {
        outcome: "confirmed",
        evidence: "Vérifié sur la blockchain, transaction 0xabc123",
        review_confirmed: "0"
      }

      assert_redirected_to admin_payment_order_path(@order)
      assert_equal "review", @order.reload.status
      assert flash[:alert].present?
    end
  end
end
