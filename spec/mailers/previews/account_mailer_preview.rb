class AccountMailerPreview < ActionMailer::Preview
  def confirmation_instructions
    @tenant = Tenant.normanglobal
    @user = @tenant.users.shipper.last
    AccountMailer.confirmation_instructions(@user, 'sdljfhalsifgh')
  end
end