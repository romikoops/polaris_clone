# frozen_string_literal: true

class WelcomeMailer < ApplicationMailer
  layout 'mailer.html.mjml'
  add_template_helper(ApplicationHelper)

  def welcome_email(user) # rubocop:disable Metrics/AbcSize
    return unless Content.exists?(tenant_id: user.tenant_id, component: 'WelcomeMail')

    @user = user
    @tenant = @user.tenant
    @theme = @tenant.theme
    @content = Content.get_component('WelcomeMail', @tenant.id)
    @scope = ::Tenants::ScopeService.new(target: @user).fetch
    attachments.inline['logo.png'] = URI.try(:open, @theme['emailLogo']).try(:read)

    attachments.inline['ngl_welcome_image.jpg'] = URI.open(
      'https://assets.itsmycargo.com/assets/tenants/normanglobal/ngl_welcome_image.jpg'
    ).read

    mail(
      from: Mail::Address.new("no-reply@#{@user.tenant.subdomain}.#{Settings.emails.domain}")
                         .tap { |a| a.display_name = @user.tenant.name }.format,
      reply_to: @user.tenant.emails.dig('support', 'general'),
      to: mail_target_interceptor(@user, @user.email),
      subject: @content['subject'][0]['text']
    ) do |format|
      format.html
      format.mjml
    end
  end
end
