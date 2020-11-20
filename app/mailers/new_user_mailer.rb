# frozen_string_literal: true

class NewUserMailer < ApplicationMailer
  default from: "ItsMyCargo Bookings <bookings@itsmycargo.com>"
  layout "mailer"
  add_template_helper(ApplicationHelper)

  def new_user_email(user:)
    @user = user
    set_current_id(organization_id: user.organization_id)
    @user_profile = Profiles::ProfileService.fetch(user_id: @user.id)
    @organization = current_organization
    @org_theme = ::Organizations::ThemeDecorator.new(@organization.theme)
    @theme = @org_theme.legacy_format
    @scope = scope_for(record: @user)

    @mot_icon = URI.open(
      "https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png"
    ).read
    email_logo = @organization.theme.email_logo
    attachments.inline["logo.png"] = email_logo.attached? ? email_logo&.download : ""
    attachments.inline["icon.png"] = @mot_icon
    email = @org_theme.emails.dig("sales", "general")

    return if email.nil?

    mail(
      from: Mail::Address.new("no-reply@#{Settings.emails.domain}")
                         .tap { |a| a.display_name = "ItsMyCargo Service Request" }.format,
      reply_to: "support@itsmycargo.com",
      to: email,
      subject: "A New User Has Registered!"
    ) do |format|
      format.html
      format.mjml
    end
  end
end
