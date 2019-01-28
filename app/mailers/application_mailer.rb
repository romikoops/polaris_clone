# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@itsmycargo.tech'
  layout 'mailer'

  def mail_target_interceptor(user, email)
    if user.internal?
      Settings.emails.booking
    else
      email
    end
  end
end
