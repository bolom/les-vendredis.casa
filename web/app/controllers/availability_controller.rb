class AvailabilityController < ApplicationController
  allow_unauthenticated_access only: :show

  def show
    check = Availability::Check.new(from: params[:from], to: params[:to])

    if check.valid?
      render json: {
        days: check.days,
        generated_at: Time.current.utc.iso8601
      }
    else
      render json: { errors: check.errors }, status: :unprocessable_entity
    end
  end
end
