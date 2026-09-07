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
      redirect_to admin_booking_inquiries_path, notice: "Booking accepted."
    rescue ActiveRecord::RecordInvalid
      redirect_to admin_booking_inquiry_path(params[:id]), alert: "Dates are no longer available."
    rescue ActiveRecord::StatementInvalid => error
      raise unless error.cause.is_a?(PG::ExclusionViolation)

      redirect_to admin_booking_inquiry_path(params[:id]), alert: "Dates are no longer available."
    end

    def decline
      inquiry = BookingInquiry.find(params[:id])
      inquiry.decline!
      redirect_to admin_booking_inquiries_path, notice: "Booking declined."
    rescue ActiveRecord::RecordInvalid
      redirect_to admin_booking_inquiry_path(params[:id]), alert: "This booking cannot be declined."
    end
  end
end
