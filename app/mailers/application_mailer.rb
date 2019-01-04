# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base

  after_action { 
    message.headers["X-INTERNAL"] = true 
  }

  default from: "itsmycargodev@gmail.com"
  layout "mailer"

  def beta_prospect_mail(prospect_name, email, company, phone)
    @prospect_name = prospect_name
    @email = email
    @company = company
    @phone = phone
    mail(to: "support@itsmycargo.com", subject: "ItsMyCargo Beta Prospect!", &:text)
  end

  def mail_target_interceptor(user, email)
    if user.internal?
      return 'bookingemails@itsmycargo.com'
    else
      return email
    end
  end
end
