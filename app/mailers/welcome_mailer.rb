# frozen_string_literal: true

class WelcomeMailer < ApplicationMailer
  layout 'mailer.html.mjml'
  add_template_helper(ApplicationHelper)

  def welcome_email(user, sandbox = nil) # rubocop:disable Metrics/AbcSize
    return unless Legacy::Content.exists?(tenant_id: user.tenant_id, component: 'WelcomeMail')

    @user = user
    @tenant = @user.tenant
    @theme = @tenant.theme
    @content = Legacy::Content.get_component('WelcomeMail', @tenant.id)
    @scope = ::Tenants::ScopeService.new(target: ::Tenants::User.find_by(legacy_id: @user.id)).fetch
    attachments.inline['logo.png'] = URI.try(:open, @theme['emailLogo']).try(:read)

    attachments.inline['ngl_welcome_image.jpg'] = URI.open(
      'https://assets.itsmycargo.com/assets/tenants/normanglobal/ngl_welcome_image.jpg'
    ).read
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
