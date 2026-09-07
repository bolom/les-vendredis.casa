class ApplicationMailer < ActionMailer::Base
  default(
    from: -> { AppConfig.fetch("MAIL_FROM", :mail, :from, default: "Les Vendredis <hello@lesvendredis.casa>") },
    reply_to: -> { AppConfig.fetch("MAIL_REPLY_TO", :mail, :reply_to, default: "hello@lesvendredis.casa") }
  )
  layout "mailer"
end
