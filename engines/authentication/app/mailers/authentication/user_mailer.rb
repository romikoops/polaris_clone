# frozen_string_literal: true

module Authentication
  class UserMailer < Authentication::ApplicationMailer
    def activation_needed_email(user)
      @user = user

      set_organization(organization_id: user.organization_id)
      @scope = ::OrganizationManager::ScopeService.new(target: user).fetch
      set_theme

      subject = "#{@org_theme.name} Account Confirmation Email"
      attachments.inline["logo.png"] = @email_logo.attached? ? @email_logo&.download : ""

      @confirmation_url = "#{base_url}authentication/confirmation/#{@user.activation_token}"

      @links = @org_theme.email_links.present? ? @org_theme.email_links["confirmation_instructions"] : []

      mail(to: user.email, from: from, reply_to: reply_to, subject: subject) do |format|
        format.mjml
      end
    end

    def activation_success_email(user)
      @user = user
      mail to: user.email
    end

    def reset_password_email(user)
      @user = user
      set_organization(organization_id: user.organization_id)
      @scope = ::OrganizationManager::ScopeService.new(target: user).fetch

      set_theme

      redirect_url = base_url + "password_reset"
      @reset_url = "/organizations/#{current_organization.id}/password_resets/#{user.reset_password_token}/edit"
      @password_reset_url = "#{base_server_url}#{@reset_url}?redirect_url=#{redirect_url}"

      attachments.inline["logo.png"] = @email_logo.attached? ? @email_logo&.download : ""
      subject = "#{@org_theme.name} Account Password Reset"

      mail(to: user.email, from: from, reply_to: reply_to, subject: subject) do |format|
        format.mjml
      end
    end

    private

    def from
      Mail::Address.new("no-reply@#{current_organization.slug}.itsmycargo.shop")
        .tap { |a| a.display_name = @org_theme.name }.format
    end

    def reply_to
      @org_theme.emails.dig("support", "general")
    end

    def base_server_url
      case Rails.env
      when "production" then "https://api.itsmycargo.com"
      when "review" then ENV["REVIEW_URL"]
      when "development", "test" then "http://localhost:3000"
      end
    end

    def base_url
      case Rails.env
      when "production" then "https://#{default_domain}/"
      when "review" then ENV["REVIEW_URL"]
      when "development", "test" then "http://localhost:8080/"
      end
    end
  end
end
