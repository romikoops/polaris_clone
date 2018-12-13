# frozen_string_literal: true

class WelcomeMailer < ApplicationMailer
  layout 'mailer.html.mjml'
  add_template_helper(ApplicationHelper)

  def welcome_email(user)
    return unless  Content.exists?(tenant_id: user.tenant_id, component: 'WelcomeMail')

    @user = user
    @tenant = @user.tenant
    @theme = @tenant.theme
    @content = Content.get_component('WelcomeMail', @tenant.id)
    
    mail(
      to: @user.email,
      subject: @content['subject'][0]&.text
    ) do |format|
      format.html
      format.mjml
    end
  end

  private

end
