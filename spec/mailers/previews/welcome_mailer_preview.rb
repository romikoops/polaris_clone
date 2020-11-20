# frozen_string_literal: true

class WelcomeMailerPreview < ActionMailer::Preview
  def welcome_email
    @org = Organizations::Organization.find_by(slug: "normanglobal")
    @user = Organizations::User.unscoped.where(organization: @org).last
    WelcomeMailer.welcome_email(@user)
  end
end
