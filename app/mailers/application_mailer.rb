class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "Yuca Alertas <alertas@yuca.local>")
  layout "mailer"
end
