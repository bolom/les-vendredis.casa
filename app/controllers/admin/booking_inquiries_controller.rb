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
      @inquiry_price = compute_inquiry_price(@booking_inquiry)
    end

    def accept
      inquiry = BookingInquiry.find(params[:id])
      BookingInquiries.accept(inquiry)
      redirect_to admin_booking_inquiry_path(inquiry), notice: "Demande acceptée : les dates sont bloquées et le voyageur notifié."
    rescue BookingInquiries::Error
      redirect_to admin_booking_inquiry_path(params[:id]), alert: "Les dates ne sont plus disponibles."
    end

    def decline
      inquiry = BookingInquiry.find(params[:id])
      BookingInquiries.decline(inquiry)
      redirect_to admin_booking_inquiry_path(inquiry), notice: "Demande refusée : le voyageur est notifié."
    rescue BookingInquiries::Error
      redirect_to admin_booking_inquiry_path(params[:id]), alert: "Cette demande ne peut pas être refusée."
    end

    def cancel
      inquiry = BookingInquiry.find(params[:id])
      BookingInquiries.cancel(inquiry)
      redirect_to admin_booking_inquiry_path(inquiry), notice: "Séjour annulé : le voyageur est notifié et les dates redeviennent disponibles."
    rescue BookingInquiries::Error
      message = inquiry.availability_block&.managed_by_payment? ?
        "Ce séjour ne peut pas être annulé : le règlement est en cours, l'annulation se fait avec Bolo." :
        "Ce séjour ne peut pas être annulé."
      redirect_to admin_booking_inquiry_path(params[:id]), alert: message
    end
    private

    # Human-language price for the inquiry screen: the configured nightly
    # price times the requested nights, when a price is configured at all.
    def compute_inquiry_price(inquiry)
      price = StayRule.current.nightly_price_eur
      return nil if price.blank?

      price * inquiry.nights
    end
  end
end
