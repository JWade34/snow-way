class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "Snow Way <powder@snowway.app>"),
          reply_to: ENV.fetch("MAIL_REPLY_TO", "justin+snowway@superdupr.com")
  layout "mailer"
end
