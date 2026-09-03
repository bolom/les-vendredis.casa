namespace :resend do
  desc "Send a staging smoke email through the configured Action Mailer delivery method"
  task smoke: :environment do
    abort "Refusing to send outside staging unless ALLOW_PRODUCTION_EMAIL_SMOKE=1" if Rails.env.production? && ENV["ALLOW_PRODUCTION_EMAIL_SMOKE"] != "1"

    recipient = ENV.fetch("RESEND_SMOKE_TO", "delivered@resend.dev")
    inquiry = BookingInquiry.new(
      check_in: Date.current + 30.days,
      check_out: Date.current + 32.days,
      adults: 2,
      children: 0,
      guest_name: "Resend smoke test",
      email: recipient,
      locale: "en",
      public_reference: "LV-SMOKE"
    )

    BookingInquiryMailer.with(booking_inquiry: inquiry).guest_acknowledgement.deliver_now
    puts "Resend smoke email sent to #{recipient}"
  end
end
