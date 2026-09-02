module Admin
  class BookingInquiriesController < ApplicationController
    def index
      @booking_inquiries = BookingInquiry.order(created_at: :desc)
    end

    def show
      @booking_inquiry = BookingInquiry.find(params[:id])
    end

    def accept
      BookingInquiry.find(params[:id]).accept!
      redirect_to admin_booking_inquiries_path, notice: "Booking accepted."
    rescue ActiveRecord::RecordInvalid
      redirect_to admin_booking_inquiry_path(params[:id]), alert: "Dates are no longer available."
    end

    def decline
      BookingInquiry.find(params[:id]).decline!
      redirect_to admin_booking_inquiries_path, notice: "Booking declined."
    end
  end
end
