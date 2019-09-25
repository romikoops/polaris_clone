# frozen_string_literal: true

class AccountMailer < Devise::Mailer
  default template_path: 'devise/mailer'
  layout 'mailer'
  helper :application
  include Devise::Controllers::UrlHelpers

  def confirmation_instructions(record, token, opts = {}) # rubocop:disable Metrics/AbcSize
    tenant = record.tenant
    @primary_color = tenant.theme.dig('colors', 'primary')

    opts[:from] = Mail::Address.new("no-reply@#{::Tenants::Tenant.find_by(legacy_id: tenant.id).slug}.itsmycargo.shop")
                               .tap { |a| a.display_name = tenant.name }.format
    opts[:reply_to] = tenant.emails.dig('support', 'general')
    attachments.inline['logo.png'] = URI.try(:open, tenant.theme['emailLogo']).try(:read)
    opts[:subject] = "#{tenant.name} Account Confirmation Email"
    @confirmation_url = "#{base_url(tenant)}account/confirmation/#{token}"

    @links = tenant.email_links ? tenant.email_links['confirmation_instructions'] : []
    @scope = ::Tenants::ScopeService.new(target: record).fetch
    WelcomeMailer.welcome_email(record).deliver_later
    NewUserMailer.new_user_email(user_id: record.id).deliver_later if @scope[:email_on_registration]
    super
  end

  def reset_password_instructions(record, token, opts = {})
    tenant = record.tenant
    @primary_color = tenant.theme.dig('colors', 'primary')
    attachments.inline['logo.png'] = URI.try(:open, tenant.theme['emailLogo']).try(:read) if tenant.theme['emailLogo']
    opts[:from] = Mail::Address.new("no-reply@#{::Tenants::Tenant.find_by(legacy_id: tenant.id).slug}.itsmycargo.shop")
                               .tap { |a| a.display_name = tenant.name }.format
    opts[:reply_to] = tenant.emails.dig('support', 'general')
    @scope = ::Tenants::ScopeService.new(target: record).fetch
    opts[:subject] = "#{tenant.name} Account Password Reset"
    redirect_url = base_url(tenant) + 'password_reset'
    @reset_url = "#{base_server_url}tenants/#{tenant.id}/auth/password/edit?" \
                 "redirect_url=#{redirect_url}&reset_password_token=#{token}"

    super
  end

  private

  def base_server_url
    case Rails.env
    when 'production'  then 'https://api.itsmycargo.com/'
    when 'review'      then ENV['REVIEW_URL']
    when 'development' then 'http://localhost:3000/'
    when 'test'        then 'http://localhost:3000/'
    end
  end

  def base_url(tenant)
    case Rails.env
    when 'production'  then "https://#{::Tenants::Tenant.find_by(legacy_id: tenant.id).default_domain}/"
    when 'review'      then ENV['REVIEW_URL']
    when 'development' then 'http://localhost:8080/'
    when 'test'        then 'http://localhost:8080/'
    end
  end
end
