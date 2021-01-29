module Notifications
  class UserMailer < ApplicationMailer
    before_action do
      attachments.inline["logo.png"] = if current_organization.theme.large_logo.attached?
        current_organization.theme.large_logo.download
      else
        ""
      end

      @user = params[:user]
      @profile = @user.profile
      @support_url = begin
        encoded_email_address = ERB::Util.url_encode(
          current_organization.theme.emails["support"]["general"]
        ).gsub("%40", "@")
        "mailto:#{encoded_email_address}"
      end
    end

    def activation_needed_email
      @confirmation_url = shop_url("authentication/confirmation/#{@user.activation_token}")

      mail to: @user.email, subject: default_i18n_subject(company: current_organization.theme.name)
    end

    def reset_password_email
      @reset_url = shop_url("password_reset?reset_password_token=#{@user.reset_password_token}")

      mail to: @user.email, subject: default_i18n_subject(company: current_organization.theme.name)
    end
  end
end
