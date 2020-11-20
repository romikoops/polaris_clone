# frozen_string_literal: true

class AccountMailerPreview < ActionMailer::Preview
  def confirmation_instructions
    @organization = Organizations::Organization.find_by(slug: "normanglobal")
    @user = Authentication::User.unscoped.where(organization_id: @organization.id).last
    @user.setup_activation
    @user.save
    Authentication::UserMailer.activation_needed_email(@user)
  end

  def reset_password_instructions
    @organization = Organizations::Organization.find_by(slug: "demo")
    @user = Authentication::User.unscoped.where(organization_id: @organization.id).last
    @user.generate_reset_password_token!
    Authentication::UserMailer.reset_password_email(@user)
  end
end
