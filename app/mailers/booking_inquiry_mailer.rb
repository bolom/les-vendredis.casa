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
    @price = StayRule.current.price_for(@booking_inquiry.nights)
    @nightly_price = StayRule.current.nightly_price_eur
    @confirmation_url = booking_inquiry_url(@booking_inquiry.public_reference, host: AppConfig.fetch("APP_HOST", :app, :host, default: "lesvendredis.casa"))
    I18n.with_locale(@booking_inquiry.locale) do
      mail(
        to: @booking_inquiry.email,
        subject: @booking_inquiry.locale == "fr" ? "Votre séjour Les Vendredis est confirmé" : "Your Les Vendredis stay is confirmed"
      )
    end
  end

  def guest_decline
    @booking_inquiry = params[:booking_inquiry]
    mail(
      to: @booking_inquiry.email,
      subject: @booking_inquiry.locale == "fr" ? "Votre demande Les Vendredis" : "Your Les Vendredis request"
    )
  end

  def guest_cancellation
    @booking_inquiry = params[:booking_inquiry]
    mail(to: @booking_inquiry.email, subject: @booking_inquiry.locale == "fr" ? "Annulation de votre séjour Les Vendredis" : "Your Les Vendredis stay cancellation")
  end
end
