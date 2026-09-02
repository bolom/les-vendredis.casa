class BookingInquiriesController < ApplicationController
  allow_unauthenticated_access

  def new
    @booking_inquiry = BookingInquiry.new(locale: locale_param)
  end

  def create
    return redirect_to new_booking_inquiry_path, alert: "Request could not be submitted." if spam?

    @booking_inquiry = BookingInquiry.new(booking_inquiry_params.merge(locale: locale_param, consent_at: Time.current))

    if @booking_inquiry.valid? && available?(@booking_inquiry) && @booking_inquiry.save
      BookingInquiryMailer.with(booking_inquiry: @booking_inquiry).owner_notification.deliver_later
      BookingInquiryMailer.with(booking_inquiry: @booking_inquiry).guest_acknowledgement.deliver_later
      redirect_to booking_inquiry_path(@booking_inquiry.public_reference)
    else
      @booking_inquiry.errors.add(:base, "These dates are no longer available") unless available?(@booking_inquiry)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @booking_inquiry = BookingInquiry.find_by!(public_reference: params[:id])
  end

  private

  def booking_inquiry_params
    params.require(:booking_inquiry).permit(:check_in, :check_out, :adults, :children, :guest_name, :email, :phone, :message)
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
