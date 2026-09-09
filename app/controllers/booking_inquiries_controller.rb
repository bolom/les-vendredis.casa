class BookingInquiriesController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 5.minutes, only: :create

  def new
    @booking_inquiry = BookingInquiry.new(locale: locale_param)
  end

  def create
    return redirect_to new_booking_inquiry_path(locale: locale_param), alert: (locale_param == "fr" ? "La demande n’a pas pu être envoyée." : "Request could not be submitted.") if spam?

    @booking_inquiry = BookingInquiry.new(booking_inquiry_params.merge(locale: locale_param))
    @booking_inquiry.contact_consent ||= "0"
    @booking_inquiry.consent_at = Time.current if @booking_inquiry.contact_consent == "1"

    if @booking_inquiry.valid?(:public_submission) && available?(@booking_inquiry) && @booking_inquiry.save(context: :public_submission)
      redirect_to booking_inquiry_path(@booking_inquiry.public_reference)
    else
      @booking_inquiry.errors.add(:base, "These dates are no longer available") unless available?(@booking_inquiry)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @booking_inquiry = BookingInquiry.find_by!(public_reference: params[:id])
    @price = StayRule.current.price_for(@booking_inquiry.nights) if @booking_inquiry.status_accepted?
  end

  private

  def booking_inquiry_params
    params.require(:booking_inquiry).permit(:check_in, :check_out, :adults, :children, :guest_name, :email, :phone, :message, :contact_consent)
  end

  def locale_param
    params[:locale].presence_in(%w[en fr]) || "en"
  end

  def spam?
    params[:company].present?
  end

  def available?(booking_inquiry)
    Availability::Check.new(from: booking_inquiry.check_in, to: booking_inquiry.check_out).available?(
      check_in: booking_inquiry.check_in,
      check_out: booking_inquiry.check_out
    )
  end
end
