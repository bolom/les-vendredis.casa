class MachineBookingsController < ApplicationController
  allow_unauthenticated_access
  skip_forgery_protection only: [ :quote, :book ]

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
      paymentConfigured: MachineBookings::Quote.pay_to.present?
    }
  end

  def quote
    booking_quote = MachineBookings::Quote.build(params)

    if booking_quote.valid?
      render json: booking_quote
    else
      render json: { errors: booking_quote.errors }, status: :unprocessable_entity
    end
  end

  def book
    booking_quote = MachineBookings::Quote.build(params)

    if booking_quote.valid?
      response.set_header("WWW-Authenticate", booking_quote.authenticate_header)
      render json: {
        error: "payment_required",
        message: "Payment verification is required before a booking can be confirmed.",
        quote: booking_quote.as_json,
        paymentMethods: [ booking_quote.payment_method ]
      }, status: :payment_required
    else
      render json: { errors: booking_quote.errors }, status: :unprocessable_entity
    end
  end
end
