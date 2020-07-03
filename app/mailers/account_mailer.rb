# frozen_string_literal: true

class AccountMailer < Devise::Mailer
  default template_path: 'devise/mailer'
  layout 'mailer'
  helper :application
  include Devise::Controllers::UrlHelpers

  def confirmation_instructions(record, token, opts = {}) # rubocop:disable Metrics/AbcSize
    set_current_id(organization_id: record.organization_id)
    @org_theme = ::Organizations::ThemeDecorator.new(current_organization.theme)
    @theme = @org_theme.legacy_format
    @primary_color = @theme.dig('colors', 'primary')
    no_reply = Mail::Address.new("no-reply@#{current_organization.slug}.itsmycargo.shop")
    opts[:from] = no_reply.tap { |a| a.display_name = @org_theme.name }.format
    opts[:reply_to] = @org_theme.emails.dig('support', 'general')
    email_logo = @org_theme.email_logo
    attachments.inline['logo.png'] = email_logo.attached? ? email_logo&.download : ''
    opts[:subject] = "#{@org_theme.name} Account Confirmation Email"
    @confirmation_url = "#{base_url(current_organization)}account/confirmation/#{token}"
    @user_profile = Profiles::ProfileService.fetch(user: record)
    @links = @org_theme.email_links ? @org_theme.email_links['confirmation_instructions'] : []
    @scope = ::OrganizationManager::ScopeService.new(target: record).fetch
    WelcomeMailer.welcome_email(record).deliver_later
    NewUserMailer.new_user_email(user_id: record.id).deliver_later if @scope[:email_on_registration]
    super
  end

  def reset_password_instructions(record, token, opts = {})
    set_current_id(organization_id: record.organization_id)
    @org_theme = ::Organizations::ThemeDecorator.new(current_organization.theme)
    @theme = @org_theme.legacy_format
    @primary_color = @theme.dig('colors', 'primary')
    email_logo = @org_theme.theme.email_logo
    attachments.inline['logo.png'] = email_logo.attached? ? email_logo&.download : ''
    opts[:from] = Mail::Address.new("no-reply@#{current_organization.slug}.itsmycargo.shop")
                               .tap { |a| a.display_name = @org_theme.name }.format
    opts[:reply_to] = @org_theme.emails.dig('support', 'general')
    @scope = ::OrganizationManager::ScopeService.new(target: record).fetch
    @user_profile = Profiles::ProfileService.fetch(user: record)
    opts[:subject] = "#{@org_theme.name} Account Password Reset"
    redirect_url = base_url(current_organization) + 'password_reset'
    @reset_url = "#{base_server_url}organizations/#{current_organization.id}/auth/password/edit?" \
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
    when 'production'  then "https://#{default_domain}/"
    when 'review'      then ENV['REVIEW_URL']
    when 'development' then 'http://localhost:8080/'
    when 'test'        then 'http://localhost:8080/'
    end
  end
end
