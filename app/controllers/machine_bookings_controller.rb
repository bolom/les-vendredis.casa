class MachineBookingsController < ApplicationController
  allow_unauthenticated_access
  skip_forgery_protection only: [ :quote, :book ]
  rate_limit to: 60, within: 1.minute, only: [ :quote, :book ]
  rescue_from MachineBookings::PaymentConfiguration::Invalid, with: :payment_unavailable
  rescue_from MachineBookings::Facilitator::Unavailable, with: :payment_unavailable
  rescue_from MachineBookings::Quote::InvalidPrice, with: :payment_unavailable
  rescue_from ActiveRecord::RecordNotFound, with: :quote_not_found

  def rules
    stay_rule = StayRule.current

    render json: {
      minNights: stay_rule.minimum_nights || 1,
      maxNights: stay_rule.maximum_nights,
      maxGuests: stay_rule.maximum_adults + stay_rule.maximum_children,
      price: MachineBookings::Quote.unit_price.to_s("F").sub(/\.0+\z/, ""),
      currency: MachineBookings::Quote.currency,
      network: MachineBookings::Quote.network,
      chainId: MachineBookings::Quote.chain_id,
      asset: MachineBookings::Quote.asset,
      payTo: MachineBookings::Quote.pay_to,
      paymentConfigured: MachineBookings::Quote.payment_configured?
    }
  end

  def quote
    booking_quote = MachineBookings::Quote.build(params)

    if booking_quote.valid?
      body = booking_quote.as_json
      if MachineBookings::Quote.payment_configured?
        order = PaymentOrder.create!(quote: body, requirements: MachineBookings::PaymentConfiguration.requirements(booking_quote), expires_at: booking_quote.expires_at)
        body = body.merge(quoteId: order.public_id, authorizationNonce: "0x#{Digest::SHA256.hexdigest(order.public_id)}")
      end
      render json: body
    else
      render json: { errors: booking_quote.errors }, status: :unprocessable_entity
    end
  end

  def book
    return payment_unavailable unless MachineBookings::Quote.payment_configured?
    order = PaymentOrder.find_by!(public_id: params[:quote_id].to_s)
    proof = request.headers["PAYMENT-SIGNATURE"]
    if proof.blank?
      return render json: { error: "quote_expired" }, status: :gone if order.expires_at <= Time.current
      response.set_header("PAYMENT-REQUIRED", Base64.strict_encode64(JSON.generate(order.challenge)))
      return render json: order.challenge, status: :payment_required
    end
    guest = params.permit(:guest_name, :email, :phone, :contact_consent).to_h.merge("locale" => (params[:locale] == "fr" ? "fr" : "en"))
    result = MachineBookings::Checkout.new(order).call(proof, guest)
    if result.status == "paid"
      response.set_header("PAYMENT-RESPONSE", Base64.strict_encode64(JSON.generate(result.settlement)))
      render json: { status: "confirmed", reference: result.booking_inquiry.public_reference }
    else
      render json: { status: "payment_review", quoteId: order.public_id }, status: :accepted
    end
  rescue MachineBookings::Checkout::Invalid, ActiveRecord::RecordInvalid
    render json: { error: "invalid_payment_or_guest" }, status: :unprocessable_entity
  rescue MachineBookings::Checkout::Conflict
    render json: { error: "booking_conflict" }, status: :conflict
  rescue MachineBookings::Checkout::Pending
    render json: { status: "payment_review" }, status: :accepted
  end

  private

  def quote_not_found
    render json: { error: "quote_not_found" }, status: :not_found
  end

  def payment_unavailable
    render json: { error: "payment_unavailable", message: "Online payment is not available. Please submit a booking request." }, status: :service_unavailable
  end
end
