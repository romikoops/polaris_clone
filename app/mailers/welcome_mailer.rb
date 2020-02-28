# frozen_string_literal: true

class WelcomeMailer < ApplicationMailer
  layout 'mailer.html.mjml'
  add_template_helper(ApplicationHelper)

  def welcome_email(user, sandbox = nil) # rubocop:disable Metrics/AbcSize
    return unless Legacy::Content.exists?(tenant_id: user.tenant_id, component: 'WelcomeMail')

    @user = user
    tenants_user = Tenants::User.find_by(legacy_id: user.id)
    @user_profile = Profiles::ProfileService.fetch(user_id: tenants_user.id)
    @tenant = @user.tenant
    @content = Legacy::Content.get_component('WelcomeMail', @tenant.id)
    @scope = scope_for(record: @user)
    @tenants_tenant = ::Tenants::Tenant.find_by(legacy_id: @user.tenant_id)
    @theme = ::Tenants::ThemeDecorator.new(@tenants_tenant.theme).legacy_format
    email_logo = @tenants_tenant.theme.email_logo
    welcome_email_image = @tenants_tenant.theme.welcome_email_image
    attachments.inline['logo.png'] = email_logo.attached? ? email_logo.download : ''
    attachments.inline['ngl_welcome_image.jpg'] = welcome_email_image.attached? ? welcome_email_image.download : ''

    subject = sandbox ? "[SANDBOX] - #{@content['subject'][0]['text']}" : @content['subject'][0]['text']

    mail(
      from: Mail::Address.new("no-reply@#{::Tenants::Tenant.find_by(legacy_id: @user.tenant.id).slug}.itsmycargo.shop")
                         .tap { |a| a.display_name = @user.tenant.name }.format,
      reply_to: @user.tenant.emails.dig('support', 'general'),
      to: mail_target_interceptor(@user, @user.email),
      subject: subject
    ) do |format|
      format.html
      format.mjml
    end
  end
end
