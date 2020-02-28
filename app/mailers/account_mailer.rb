# frozen_string_literal: true

class AccountMailer < Devise::Mailer
  default template_path: 'devise/mailer'
  layout 'mailer'
  helper :application
  include Devise::Controllers::UrlHelpers

  def confirmation_instructions(record, token, opts = {}) # rubocop:disable Metrics/AbcSize
    tenant = Tenant.find(record.tenant_id)
    tenants_tenant = ::Tenants::Tenant.find_by(legacy_id: record.tenant_id)
    @theme = ::Tenants::ThemeDecorator.new(tenants_tenant.theme).legacy_format
    @primary_color = @theme.dig('colors', 'primary')
    no_reply = Mail::Address.new("no-reply@#{tenants_tenant.slug}.itsmycargo.shop")
    opts[:from] = no_reply.tap { |a| a.display_name = tenant.name }.format
    opts[:reply_to] = tenant.emails.dig('support', 'general')
    email_logo = tenants_tenant.theme.email_logo
    attachments.inline['logo.png'] = email_logo.attached? ? email_logo&.download : ''
    opts[:subject] = "#{tenant.name} Account Confirmation Email"
    @confirmation_url = "#{base_url(tenants_tenant)}account/confirmation/#{token}"
    tenants_user = Tenants::User.find_by(legacy_id: record.id)
    @user_profile = Profiles::ProfileService.fetch(user_id: tenants_user.id)
    @links = tenant.email_links ? tenant.email_links['confirmation_instructions'] : []
    @scope = ::Tenants::ScopeService.new(target: ::Tenants::User.find_by(legacy_id: record.id)).fetch
    WelcomeMailer.welcome_email(record).deliver_later
    NewUserMailer.new_user_email(user_id: record.id).deliver_later if @scope[:email_on_registration]
    super
  end

  def reset_password_instructions(record, token, opts = {})
    tenant = Tenant.find(record.tenant_id)
    tenants_tenant = ::Tenants::Tenant.find_by(legacy_id: record.tenant_id)
    @theme = ::Tenants::ThemeDecorator.new(tenants_tenant.theme).legacy_format
    @primary_color = @theme.dig('colors', 'primary')
    email_logo = tenants_tenant.theme.email_logo
    attachments.inline['logo.png'] = email_logo.attached? ? email_logo&.download : ''
    opts[:from] = Mail::Address.new("no-reply@#{tenants_tenant.slug}.itsmycargo.shop")
                               .tap { |a| a.display_name = tenant.name }.format
    opts[:reply_to] = tenant.emails.dig('support', 'general')
    @scope = ::Tenants::ScopeService.new(target: ::Tenants::User.find_by(legacy_id: record.id)).fetch
    tenants_user = Tenants::User.find_by(legacy_id: record.id)
    @user_profile = Profiles::ProfileService.fetch(user_id: tenants_user.id)
    opts[:subject] = "#{tenant.name} Account Password Reset"
    redirect_url = base_url(tenants_tenant) + 'password_reset'
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
    when 'production'  then "https://#{tenant.default_domain}/"
    when 'review'      then ENV['REVIEW_URL']
    when 'development' then 'http://localhost:8080/'
    when 'test'        then 'http://localhost:8080/'
    end
  end
end
