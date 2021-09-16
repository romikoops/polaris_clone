# frozen_string_literal: true

module Notifications
  class UserMailer < ApplicationMailer
    before_action do
      attachments.inline["logo.png"] = logo_for_attaching
      @user = params[:user]
      @profile = @user.profile
      @support_url = "mailto:#{encoded_email_address}"
    end

    def activation_needed_email
      @confirmation_url = shop_url("authentication/confirmation/#{@user.activation_token}")

      mail to: @user.email, subject: default_i18n_subject(company: company_name)
    end

    def reset_password_email
      @reset_url = shop_url("password_reset?reset_password_token=#{@user.reset_password_token}")

      mail to: @user.email, subject: default_i18n_subject(company: company_name)
    end

    def logo_for_attaching
      return File.expand_path("../../assets/images/notifications/logo-blue.png", __dir__) if admin?

      if current_organization.theme.large_logo.attached?
        current_organization.theme.large_logo.download
      else
        File.expand_path("../../assets/images/notifications/logo-blue.png", __dir__)
      end
    end

    def encoded_email_address
      email_address = if current_organization
        current_organization.theme.emails["support"]["general"]
      else
        ADMIN_SUPPORT_EMAIL
      end
      ERB::Util.url_encode(email_address).gsub("%40", "@")
    end

    def company_name
      @company_name ||= if admin?
        IMC_COMPANY_NAME
      else
        current_organization.theme.name
        end
    end

    def admin?
      @user.is_a?(Users::User)
    end
  end
end
