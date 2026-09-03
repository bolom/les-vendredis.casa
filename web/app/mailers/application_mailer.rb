class ApplicationMailer < ActionMailer::Base
  default(
    from: ENV.fetch("MAIL_FROM", "Les Vendredis <hello@lesvendredis.casa>"),
    reply_to: ENV.fetch("MAIL_REPLY_TO", "hello@lesvendredis.casa")
  )
  layout "mailer"
end
