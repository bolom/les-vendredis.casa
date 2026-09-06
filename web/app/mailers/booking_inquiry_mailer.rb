class BookingInquiryMailer < ApplicationMailer
  default to: -> { AppConfig.fetch("BOOKING_OWNER_EMAIL", :mail, :owner, default: "hello@lesvendredis.casa") }

  def owner_notification
    @booking_inquiry = params[:booking_inquiry]
    mail(subject: "New direct booking request #{@booking_inquiry.public_reference}")
  end

  def guest_acknowledgement
    @booking_inquiry = params[:booking_inquiry]
    mail(
      to: @booking_inquiry.email,
      subject: @booking_inquiry.locale == "fr" ? "Votre demande Les Vendredis" : "Your Les Vendredis request"
    )
  end

  def guest_acceptance
    @booking_inquiry = params[:booking_inquiry]
    mail(
      to: @booking_inquiry.email,
      subject: @booking_inquiry.locale == "fr" ? "Votre séjour Les Vendredis est confirmé" : "Your Les Vendredis stay is confirmed"
    )
  end

  def guest_decline
    @booking_inquiry = params[:booking_inquiry]
    mail(
      to: @booking_inquiry.email,
      subject: @booking_inquiry.locale == "fr" ? "Votre demande Les Vendredis" : "Your Les Vendredis request"
    )
  end
end
