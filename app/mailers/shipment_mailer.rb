# frozen_string_literal: true

class ShipmentMailer < ApplicationMailer
  default from: 'ItsMyCargo Bookings <bookings@itsmycargo.com>'
  layout 'mailer'
  add_template_helper(ApplicationHelper)

  TESTING_EMAIL = 'angelica@itsmycargo.com'

  def tenant_notification(user, shipment) # rubocop:disable Metrics/AbcSize
    set_current_id(organization_id: shipment.organization_id)
    @user = user
    @user_profile = Profiles::ProfileService.fetch(user_id: @user&.id)
    @scope = scope_for(record: @user)
    @shipment = Legacy::ShipmentDecorator.new(shipment, context: { scope: @scope})
    @organization = ::Organizations::Organization.current
    @org_theme = ::Organizations::ThemeDecorator.new(@organization.theme)
    @theme = @org_theme.legacy_format

    @redirects_base_url = base_url + "redirects/shipments/#{@shipment.id}?action="

    @shipment_page =
      "#{@redirects_base_url}edit"
    @mot_icon = URI.open(
      "https://assets.itsmycargo.com/assets/icons/mail/mail_#{@shipment.mode_of_transport}.png"
    ).read

    create_pdf_attachment(@shipment)
    email_logo = @org_theme.email_logo
    attachments.inline['logo.png'] = email_logo.attached? ? @org_theme.email_logo&.download : ''
    attachments.inline['icon.png'] = @mot_icon
    mail_options = {
      from: Mail::Address.new("no-reply@#{@organization.slug}.itsmycargo.shop")
                         .tap { |a| a.display_name = 'ItsMyCargo Bookings' }.format,
      reply_to: 'support@itsmycargo.com',
      to: mail_target_interceptor(@shipment.billing, @org_theme.email_for(:sales, shipment.mode_of_transport)),
      subject: subject_line(shipment: @shipment, type: :shipment, references: [@shipment.imc_reference])
    }

    mail(mail_options, &:html)
  end

  def shipper_notification(user, shipment) # rubocop:disable Metrics/AbcSize
    set_current_id(organization_id: shipment.organization_id)
    @user = user
    @user_profile = Profiles::ProfileService.fetch(user_id: @user&.id)
    @scope = scope_for(record: @user)
    @shipment = Legacy::ShipmentDecorator.new(shipment, context: { scope: @scope})
    @organization = ::Organizations::Organization.current
    @org_theme = ::Organizations::ThemeDecorator.new(@organization.theme)
    @theme = @org_theme.legacy_format
    @shipment_page = "#{base_url}account/shipments/view/#{shipment.id}"
    @mot_icon = URI.open(
      "https://assets.itsmycargo.com/assets/icons/mail/mail_#{@shipment.mode_of_transport}.png"
    ).read

    create_pdf_attachment(@shipment)
    email_logo = @org_theme.email_logo
    attachments.inline['logo.png'] = email_logo.attached? ? @org_theme.email_logo&.download : ''
    small_logo = @org_theme.small_logo
    attachments.inline['logo_small.png'] = small_logo.attached? ? small_logo&.download : ''
    attachments.inline['icon.png'] = @mot_icon
    no_reply = Mail::Address.new("no-reply@#{@organization.slug}.itsmycargo.shop")

    mail_options = {
      from: no_reply.tap { |a| a.display_name = @org_theme.name }.format,
      reply_to: @org_theme.emails.dig('support', 'general'),
      to: mail_target_interceptor(@shipment.billing, @user.email.blank? ? 'itsmycargodev@gmail.com' : @user.email),
      bcc: [Settings.emails.booking],
      subject: subject_line(shipment: @shipment, type: :shipment, references: [@shipment.imc_reference])
    }

    mail(mail_options, &:html)
  end

  def shipper_confirmation(user, shipment) # rubocop:disable Metrics/AbcSize
    set_current_id(organization_id: shipment.organization_id)
    @user = user
    @user_profile = Profiles::ProfileService.fetch(user_id: @user&.id)
    @shipment = shipment
    @scope = scope_for(record: @user)
    @organization = ::Organizations::Organization.current
    @org_theme = ::Organizations::ThemeDecorator.new(@organization.theme)
    @theme = @org_theme.legacy_format
    @shipment_page = "#{base_url}account/shipments/view/#{shipment.id}"
    @mot_icon = URI.open(
      "https://assets.itsmycargo.com/assets/icons/mail/mail_#{@shipment.mode_of_transport}.png"
    ).read

    create_pdf_attachment(@shipment)
    email_logo = @org_theme.email_logo
    attachments.inline['logo.png'] = email_logo.attached? ? email_logo&.download : ''
    small_logo = @org_theme.small_logo
    attachments.inline['logo_small.png'] = small_logo.attached? ? small_logo&.download : ''
    attachments.inline['icon.png'] = @mot_icon
    mail_options = {
      from: Mail::Address.new("no-reply@#{@organization.slug}.itsmycargo.shop")
                         .tap { |a| a.display_name = @org_theme.name }.format,
      reply_to: @org_theme.emails.dig('support', 'general'),
      to: mail_target_interceptor(@shipment.billing, user.email.presence || 'itsmycargodev@gmail.com'),
      bcc: [Settings.emails.booking],
      subject: subject_line(shipment: @shipment, type: :shipment, references: [@shipment.imc_reference])
    }

    mail(mail_options, &:html)
  end

  private

  def generate_and_upload_bill_of_lading
    bill_of_lading = Pdf::Handler.new(
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
    pdf = ShippingTools.new.generate_shipment_pdf(shipment: shipment)
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

  def base_url
    case Rails.env
    when 'production'  then "https://#{default_domain}/"
    when 'review'      then ENV['REVIEW_URL']
    when 'development' then 'http://localhost:8080/'
    when 'test'        then 'http://localhost:8080/'
    end
  end
end
