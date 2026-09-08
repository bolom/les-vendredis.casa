module Admin
  class BookingInquiriesController < BaseController
    def index
      @booking_inquiries = BookingInquiry.order(created_at: :desc)
      @booking_inquiries = @booking_inquiries.where(status: params[:status]) if params[:status].in?(BookingInquiry.statuses.keys)
      if params[:q].present?
        needle = "%#{params[:q].strip}%"
        @booking_inquiries = @booking_inquiries.where(
          "public_reference ILIKE :needle OR guest_name ILIKE :needle OR email ILIKE :needle",
          needle: needle
        )
      end
    end

    def show
      @booking_inquiry = BookingInquiry.find(params[:id])
    end

    def accept
      inquiry = BookingInquiry.find(params[:id])
      inquiry.accept!
      redirect_to admin_booking_inquiry_path(inquiry), notice: "Demande acceptée : les dates sont bloquées et le voyageur notifié."
    rescue ActiveRecord::RecordInvalid
      redirect_to admin_booking_inquiry_path(params[:id]), alert: "Les dates ne sont plus disponibles."
    rescue ActiveRecord::StatementInvalid => error
      raise unless error.cause.is_a?(PG::ExclusionViolation)

      redirect_to admin_booking_inquiry_path(params[:id]), alert: "Les dates ne sont plus disponibles."
    end

    def decline
      inquiry = BookingInquiry.find(params[:id])
      inquiry.decline!
      redirect_to admin_booking_inquiry_path(inquiry), notice: "Demande refusée : le voyageur est notifié."
    rescue ActiveRecord::RecordInvalid
      redirect_to admin_booking_inquiry_path(params[:id]), alert: "Cette demande ne peut pas être refusée."
    end
  end
end
