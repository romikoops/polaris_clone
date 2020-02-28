# frozen_string_literal: true

class ShipmentMailer < ApplicationMailer
  default from: 'ItsMyCargo Bookings <bookings@itsmycargo.com>'
  layout 'mailer'
  add_template_helper(ApplicationHelper)

  TESTING_EMAIL = 'angelica@itsmycargo.com'

  def tenant_notification(user, shipment, sandbox = nil) # rubocop:disable Metrics/AbcSize
    @user = user
    @user_profile = ProfileTools.profile_for_user(legacy_user: @user)
    tenant = user.tenant
    @shipment = shipment
    @scope = scope_for(record: @user)
    @tenants_tenant = ::Tenants::Tenant.find_by(legacy_id: @user.tenant_id)
    @theme = ::Tenants::ThemeDecorator.new(@tenants_tenant.theme).legacy_format
    base_url = base_url(tenant)

    @redirects_base_url = base_url + "redirects/shipments/#{@shipment.id}?action="

    @shipment_page =
      "#{@redirects_base_url}edit"
    @mot_icon = URI.open(
      "https://assets.itsmycargo.com/assets/icons/mail/mail_#{@shipment.mode_of_transport}.png"
    ).read

    create_pdf_attachment(@shipment)
    email_logo = @tenants_tenant.theme.email_logo
    attachments.inline['logo.png'] = email_logo.attached? ? @tenants_tenant.theme.email_logo&.download : ''
    attachments.inline['icon.png'] = @mot_icon
    mail_options = {
      from: Mail::Address.new("no-reply@#{@tenants_tenant.slug}.itsmycargo.shop")
                         .tap { |a| a.display_name = 'ItsMyCargo Bookings' }.format,
      reply_to: 'support@itsmycargo.com',
      to: mail_target_interceptor(@user, tenant.email_for(:sales, shipment.mode_of_transport)),
      subject: "#{sandbox ? '[SANDBOX] - ' : ''}Your booking through #{tenant.name}"
    }

    mail(mail_options, &:html)
  end

  def shipper_notification(user, shipment, sandbox = nil) # rubocop:disable Metrics/AbcSize
    @user = user
    @user_profile = ProfileTools.profile_for_user(legacy_user: @user)
    tenant = user.tenant
    @shipment = shipment
    @scope = scope_for(record: @user)
    @tenants_tenant = ::Tenants::Tenant.find_by(legacy_id: @user.tenant_id)
    @theme = ::Tenants::ThemeDecorator.new(@tenants_tenant.theme).legacy_format
    @shipment_page = "#{base_url(tenant)}account/shipments/view/#{shipment.id}"
    @mot_icon = URI.open(
      "https://assets.itsmycargo.com/assets/icons/mail/mail_#{@shipment.mode_of_transport}.png"
    ).read

    create_pdf_attachment(@shipment)
    email_logo = @tenants_tenant.theme.email_logo
    attachments.inline['logo.png'] = email_logo.attached? ? @tenants_tenant.theme.email_logo&.download : ''
    small_logo = @tenants_tenant.theme.small_logo
    attachments.inline['logo_small.png'] = small_logo.attached? ? small_logo&.download : ''
    attachments.inline['icon.png'] = @mot_icon
    no_reply = Mail::Address.new("no-reply@#{@tenants_tenant.slug}.itsmycargo.shop")
    mail_options = {
      from: no_reply.tap { |a| a.display_name = tenant.name }.format,
      reply_to: tenant.emails.dig('support', 'general'),
      to: mail_target_interceptor(@user, @user.email.blank? ? 'itsmycargodev@gmail.com' : @user.email),
      bcc: [Settings.emails.booking],
      subject: "#{sandbox ? '[SANDBOX] - ' : ''}Your booking through #{tenant.name}"
    }

    mail(mail_options, &:html)
  end

  def shipper_confirmation(user, shipment, sandbox = nil) # rubocop:disable Metrics/AbcSize
    @user = user
    @user_profile = ProfileTools.profile_for_user(legacy_user: @user)
    @shipment = shipment
    tenant = Tenant.find(shipment.tenant_id)
    @scope = scope_for(record: @user)
    @tenants_tenant = ::Tenants::Tenant.find_by(legacy_id: @user.tenant_id)
    @theme = ::Tenants::ThemeDecorator.new(@tenants_tenant.theme).legacy_format
    @shipment_page = "#{base_url(tenant)}account/shipments/view/#{shipment.id}"
    @mot_icon = URI.open(
      "https://assets.itsmycargo.com/assets/icons/mail/mail_#{@shipment.mode_of_transport}.png"
    ).read

    create_pdf_attachment(@shipment)
    email_logo = @tenants_tenant.theme.email_logo
    attachments.inline['logo.png'] = email_logo.attached? ? email_logo&.download : ''
    small_logo = @tenants_tenant.theme.small_logo
    attachments.inline['logo_small.png'] = small_logo.attached? ? small_logo&.download : ''
    attachments.inline['icon.png'] = @mot_icon
    mail_options = {
      from: Mail::Address.new("no-reply@#{@tenants_tenant.slug}.itsmycargo.shop")
                         .tap { |a| a.display_name = tenant.name }.format,
      reply_to: tenant.emails.dig('support', 'general'),
      to: mail_target_interceptor(@user, user.email.presence || 'itsmycargodev@gmail.com'),
      bcc: [Settings.emails.booking],
      subject: "#{sandbox ? '[SANDBOX] - ' : ''}Your booking through #{tenant.name}"
    }

    mail(mail_options, &:html)
  end

  private

  def generate_and_upload_bill_of_lading
    bill_of_lading = PdfHandler.new(
      layout: 'pdfs/simple.pdf.html.erb',
      template: 'shipments/pdfs/bill_of_lading.pdf.html.erb',
      margin: { top: 10, bottom: 5, left: 8, right: 8 },
      shipment: @shipment,
      name: 'bill_of_lading'
    )

    bill_of_lading.generate
    bill_of_lading.upload
  end

  def create_pdf_attachment(shipment)
    pdf = ShippingTools.generate_shipment_pdf(shipment: shipment)
    attachments["shipment_#{shipment.imc_reference}.pdf"] = pdf
  end

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
