# frozen_string_literal: true

class NewUserMailer < ApplicationMailer
  default from: 'ItsMyCargo Bookings <bookings@itsmycargo.com>'
  layout 'mailer'
  add_template_helper(ApplicationHelper)

  def new_user_email(user_id:) # rubocop:disable Metrics/AbcSize
    @user = User.find(user_id)
    @tenant = Tenant.find(@user.tenant_id)
    @tenants_tenant = ::Tenants::Tenant.find_by(legacy_id: @user.tenant_id)
    @theme =::Tenants::ThemeDecorator.new(@tenants_tenant.theme).legacy_format
    @scope = ::Tenants::ScopeService.new(target: @user).fetch

    @mot_icon = URI.open(
      'https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png'
    ).read

    attachments.inline['logo.png'] = @tenants_tenant.theme.email_logo.attached? ? @tenants_tenant.theme.email_logo&.download : ''
    attachments.inline['icon.png'] = @mot_icon
    email = @tenant.emails.dig('sales', 'general')

    return if email.nil?

    mail(
      from: Mail::Address.new("no-reply@#{Settings.emails.domain}")
                         .tap { |a| a.display_name = 'ItsMyCargo Service Request' }.format,
      reply_to: 'support@itsmycargo.com',
      to: mail_target_interceptor(@user, email),
      subject: 'A New User Has Registered!'
    ) do |format|
      format.html
      format.mjml
    end
  end
end
