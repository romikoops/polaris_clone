# frozen_string_literal: true

class WelcomeMailer < ApplicationMailer
  layout 'mailer.html.mjml'
  add_template_helper(ApplicationHelper)

  def welcome_email(user, sandbox = nil) # rubocop:disable Metrics/AbcSize
    set_current_id(organization_id: user.organization_id)
    return unless Legacy::Content.exists?(organization_id: user.organization_id, component: 'WelcomeMail')

    @user = user
    @user_profile = Profiles::ProfileService.fetch(user_id: user.id)
    @organization = Organizations::Organization.current
    @content = Legacy::Content.get_component('WelcomeMail', @user.organization_id)
    @scope = scope_for(record: @user)
    @org_theme = ::Organizations::ThemeDecorator.new(@organization.theme)
    @theme = @org_theme.legacy_format
    email_logo = @organization.theme.email_logo
    welcome_email_image = @organization.theme.welcome_email_image
    attachments.inline['logo.png'] = email_logo.attached? ? email_logo.download : ''
    attachments.inline['ngl_welcome_image.jpg'] = welcome_email_image.attached? ? welcome_email_image.download : ''

    subject = sandbox ? "[SANDBOX] - #{@content['subject'][0]['text']}" : @content['subject'][0]['text']

    mail(
      from: Mail::Address.new("no-reply@#{@organization.slug}.itsmycargo.shop")
                         .tap { |a| a.display_name = @org_theme.name }.format,
      reply_to: @org_theme.emails.dig('support', 'general'),
      to: @user.email,
      subject: subject
    ) do |format|
      format.html
      format.mjml
    end
  end
end
