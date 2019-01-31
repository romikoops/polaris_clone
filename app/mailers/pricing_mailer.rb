# frozen_string_literal: true

class PricingMailer < ApplicationMailer
  default from: 'ItsMyCargo Bookings <bookings@itsmycargo.com>'
  layout 'mailer'
  add_template_helper(ApplicationHelper)

  def request_email(user_id:, pricing_id:, tenant_id:, status: 'requested') # rubocop:disable Metrics/AbcSize
    @pricing = Pricing.find(pricing_id)
    @user = User.find(user_id)
    @itinerary = @pricing.itinerary
    @tenant = Tenant.find(tenant_id)
    @theme = @tenant.theme

    @mot_icon = URI.open(
      "https://assets.itsmycargo.com/assets/icons/mail/mail_#{@itinerary.mode_of_transport}.png"
    ).read

    attachments.inline['logo.png'] = URI.try(:open, @tenant.theme['emailLogo']).try(:read)
    attachments.inline['icon.png'] = @mot_icon
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
