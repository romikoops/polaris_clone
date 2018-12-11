# frozen_string_literal: true

class WelcomeMailer < ApplicationMailer
  layout 'mailer'
  add_template_helper(ApplicationHelper)

  def welcome_email(user)
    @user = user
    tenant = @user.tenant
    @theme = tenant.theme
    @content = Content.get_component('WelcomeMail', tenant.id)
    # binding.pry
    mail(
      to: 'warwick@itsmycargo.com',
      # to: @user.email,
      subject: @content['subject'][0]&.text
    ) do |format|
      format.html
      format.mjml
    end
  end

  private

end
