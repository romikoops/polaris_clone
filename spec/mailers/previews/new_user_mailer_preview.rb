# frozen_string_literal: true

class NewUserMailerPreview < ActionMailer::Preview
  def new_user_email
    @tenant = Tenant.find_by(subdomain: 'normanglobal')
    @user = @tenant.users.shipper.first
    NewUserMailer.new_user_email(user_id: @user.id)
  end
end
