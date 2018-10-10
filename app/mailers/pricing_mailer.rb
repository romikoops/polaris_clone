# frozen_string_literal: true

class PricingMailer < ApplicationMailer
  default from: 'ItsMyCargo Bookings <bookings@itsmycargo.com>'
  layout 'mailer'
  add_template_helper(ApplicationHelper)
  TEST_EMAIL = 'warwick@itsmycargo.com'
  def request_email(user_id:, pricing_id:, tenant_id:, status:)
    @pricing = Pricing.find(pricing_id)
    @user = User.find(user_id)
    @itinerary = @pricing.itinerary
    @tenant = Tenant.find(tenant_id)
    @theme = @tenant.theme

    attachments.inline['logo.png'] = URI.open(@theme['logoLarge']).read

    mail(
      # to: @tenant.emails['sales']['general'],
      to: TEST_EMAIL,
      subject: "New Rate Request for #{@itinerary.name} from #{@user.full_name}"
    ) do |format|
      format.html
      format.mjml
    end
  end

  private

end
