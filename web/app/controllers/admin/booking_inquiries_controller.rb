module Admin
  class BookingInquiriesController < ApplicationController
    def index
      @booking_inquiries = BookingInquiry.order(created_at: :desc)
    end

    def show
      @booking_inquiry = BookingInquiry.find(params[:id])
    end

    def accept
      inquiry = BookingInquiry.find(params[:id])
      inquiry.accept!
      BookingInquiryMailer.with(booking_inquiry: inquiry).guest_acceptance.deliver_later
      redirect_to admin_booking_inquiries_path, notice: "Booking accepted."
    rescue ActiveRecord::RecordInvalid
      redirect_to admin_booking_inquiry_path(params[:id]), alert: "Dates are no longer available."
    end

    def decline
      inquiry = BookingInquiry.find(params[:id])
      inquiry.decline!
      BookingInquiryMailer.with(booking_inquiry: inquiry).guest_decline.deliver_later
      redirect_to admin_booking_inquiries_path, notice: "Booking declined."
    end
  end
end
