# frozen_string_literal: true

class AccountMailerPreview < ActionMailer::Preview
  def confirmation_instructions
    @tenant = Tenant.find_by(subdomain: 'normanglobal')
    @user = @tenant.users.shipper.last
    AccountMailer.confirmation_instructions(@user, 'sdljfhalsifgh')
  end
end
