# frozen_string_literal: true

class WelcomeMailerPreview < ActionMailer::Preview
  def welcome_email
    @tenant = Tenant.find_by(subdomain: 'normanglobal')
    @user = @tenant.users.shipper.last
    WelcomeMailer.welcome_email(@user)
  end
end
