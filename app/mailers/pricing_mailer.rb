# frozen_string_literal: true

class PricingMailer < ApplicationMailer
  default from: 'ItsMyCargo Bookings <bookings@itsmycargo.com>'
  layout 'mailer'
  add_template_helper(ApplicationHelper)

  def request_email(user_id:, pricing_id:, tenant_id:, status: 'requested') # rubocop:disable Metrics/AbcSize
    @pricing = Pricing.find(pricing_id)
    @user = User.find(user_id)
    @user_profile = ProfileTools.profile_for_user(legacy_user: @user)
    @itinerary = @pricing.itinerary
    @tenant = Tenant.find(tenant_id)
    @tenants_tenant = ::Tenants::Tenant.find_by(legacy_id: @user.tenant_id)
    @theme = ::Tenants::ThemeDecorator.new(@tenants_tenant.theme).legacy_format
    @scope = scope_for(record: @user)
    @mot_icon = URI.open(
      "https://assets.itsmycargo.com/assets/icons/mail/mail_#{@itinerary.mode_of_transport}.png"
    ).read
    email_logo = @tenants_tenant.theme.email_logo
    attachments.inline['logo.png'] = email_logo.attached? ? email_logo&.download : ''
    attachments.inline['icon.png'] = @mot_icon
    email = @tenant.emails.dig('sales', 'general')

    return if email.nil?

    mail(
      from: Mail::Address.new("no-reply@#{Settings.emails.domain}")
                         .tap { |a| a.display_name = 'ItsMyCargo Service Request' }.format,
      reply_to: 'support@itsmycargo.com',
      to: mail_target_interceptor(@user, email),
      subject: "New Rate Request for #{@itinerary.name} from #{@user_profile.full_name}"
    ) do |format|
      format.html
      format.mjml
    end
  end
end
