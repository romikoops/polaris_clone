# frozen_string_literal: true

class AccountMailer < Devise::Mailer
  default template_path: 'devise/mailer'
  layout 'mailer'
  helper :application
  include Devise::Controllers::UrlHelpers

  def confirmation_instructions(record, token, opts = {})
    tenant = record.tenant
    @primary_color = tenant.theme.dig('colors', 'primary')

    attachments.inline['logo.png'] = URI.open(tenant.theme['logoLarge']).read
    opts[:from] = tenant.emails.dig('support', 'general')
    opts[:subject] = "#{tenant.name} Account Confirmation Email"

    @confirmation_url = "#{base_url(tenant)}account/confirmation/#{token}"

    @links = tenant.email_links ? tenant.email_links['confirmation_instructions'] : []

    WelcomeMailer.welcome_email(record).deliver_later
    super
  end

  def reset_password_instructions(record, token, opts = {})
    tenant = record.tenant
    @primary_color = tenant.theme.dig('colors', 'primary')

    attachments.inline['logo.png'] = URI.open(tenant.theme['logoLarge']).read
    opts[:from] = tenant.emails.dig('support', 'general')
    opts[:subject] = "#{tenant.name} Account Password Reset"
    redirect_url = base_url(tenant) + 'password_reset'
    @reset_url = "#{base_server_url}tenants/#{tenant.id}/auth/password/edit?redirect_url=#{redirect_url}&reset_password_token=#{token}"

    super
  end

  private

  def base_server_url
    case Rails.env
    when 'production'  then 'https://api.itsmycargo.com/'
    when 'review'      then "https://api.#{ENV['REVIEW_URL']}"
    when 'development' then 'http://localhost:3000/'
    when 'test'        then 'http://localhost:3000/'
    end
  end

  def base_url(tenant)
    case Rails.env
    when 'production'  then "https://#{tenant.subdomain}.itsmycargo.com/"
    when 'review'      then "https://#{tenant.subdomain}.#{ENV['REVIEW_URL']}"
    when 'development' then 'http://localhost:8080/'
    when 'test'        then 'http://localhost:8080/'
    end
  end
end
