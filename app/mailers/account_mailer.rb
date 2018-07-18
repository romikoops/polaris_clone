# frozen_string_literal: true

class AccountMailer < Devise::Mailer
  default template_path: "devise/mailer"
  layout "mailer"
  helper :application
  include Devise::Controllers::UrlHelpers

  def confirmation_instructions(record, token, opts={})
    tenant = record.tenant

    attachments.inline["logo.png"] = URI.open(tenant.theme["logoLarge"]).read

    opts[:subject] = "ItsMyCargo Account Email Confirmation"
    redirect_url = base_url(tenant) + "account"
    @confirmation_url = "https://api.itsmycargo.com/subdomain/#{tenant.subdomain}/auth/confirmation?confirmation_token=#{token}&redirect_url=#{redirect_url}"
    
    @links = tenant.email_links ? tenant.email_links["confirmation_instructions"] : []

    # headers["Custom-header"] = "Some Headers"
    # opts[:reply_to] = 'example@email.com'
    super
  end

  def reset_password_instructions(record, token, opts={})
    tenant = record.tenant

    attachments.inline["logo.png"] = URI.open(tenant.theme["logoLarge"]).read

    opts[:subject] = "ItsMyCargo Account Password Reset"
    @redirect_url = base_url(tenant) + "password_reset"

    # headers["Custom-header"] = "Some Headers"
    # opts[:reply_to] = 'example@email.com'
    super
  end

  private

  def base_url(tenant)
    case Rails.env
    when "production"  then "https://#{tenant.subdomain}.itsmycargo.com/"
    when "development" then "http://localhost:8080/"
    when "test"        then "http://localhost:8080/"
    end
  end
end
