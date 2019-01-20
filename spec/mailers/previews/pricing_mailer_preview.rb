# frozen_string_literal: true

class PricingMailerPreview < ActionMailer::Preview
  def request_email
    @pricing = Pricing.last
    @tenant = @pricing.tenant
    @user = @tenant.users.shipper.first
    PricingMailer.request_email(user_id: @user.id, pricing_id: @pricing.id, tenant_id: @tenant.id, status: 'requested')
  end
end
