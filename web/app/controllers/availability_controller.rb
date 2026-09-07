class AvailabilityController < ApplicationController
  allow_unauthenticated_access only: :show
  rescue_from MachineBookings::Quote::InvalidPrice do
    render json: { error: "pricing_unavailable" }, status: :service_unavailable
  end

  def show
    return if params[:from].blank? && params[:to].blank?

    check = Availability::Check.new(from: params[:from], to: params[:to])

    if check.valid?
      render json: {
        days: check.days.map { |day| day.merge(price: MachineBookings::Quote.unit_price.to_s("F").sub(/\.0+\z/, ""), currency: MachineBookings::Quote.currency) },
        generated_at: Time.current.utc.iso8601
      }
    else
      render json: { errors: check.errors }, status: :unprocessable_entity
    end
  end
end
