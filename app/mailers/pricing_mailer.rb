# frozen_string_literal: true

class PricingMailer < ApplicationMailer
  default from: 'ItsMyCargo Bookings <bookings@itsmycargo.com>'
  layout 'mailer'
  add_template_helper(ApplicationHelper)

  def request_email(user_id:, pricing_id:, tenant_id:, status: 'requested')
    @pricing = Pricing.find(pricing_id)
    @user = User.find(user_id)
    @itinerary = @pricing.itinerary
    @tenant = Tenant.find(tenant_id)
    @theme = @tenant.theme

    @mot =
      case @itinerary.mode_of_transport
      when 'ocean' then 'https://assets.itsmycargo.com/assets/icons/mots/mot-01.png'
      when 'air' then 'https://assets.itsmycargo.com/assets/icons/mots/mot-02.png'
      when 'truck' then 'https://assets.itsmycargo.com/assets/icons/mots/mot-03.png'
      when 'rail' then 'https://assets.itsmycargo.com/assets/icons/mots/mot-04.png'
      end

    attachments.inline['logo.png'] = URI.open(@theme['logoLarge']).read
    attachments.inline['icon.png'] = URI.open(@mot).read
    email = @tenant.emails.dig('sales', 'general')

    return if email.nil?

    mail(
      from: Mail::Address.new("no-reply@#{Settings.emails.domain}")
                         .tap { |a| a.display_name = 'ItsMyCargo Service Request' }.format,
      reply_to: 'support@itsmycargo.com',
      to: mail_target_interceptor(@user, email),
      subject: "New Rate Request for #{@itinerary.name} from #{@user.full_name}"
    ) do |format|
      format.html
      format.mjml
    end
  end
end
