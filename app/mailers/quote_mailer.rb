# frozen_string_literal: true

class QuoteMailer < ApplicationMailer
  default from: 'ItsMyCargo Bookings <bookings@itsmycargo.com>'
  layout 'mailer'
  add_template_helper(ApplicationHelper)

  def quotation_email(shipment, shipments, email, quotation, sandbox = nil) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    set_current_id(organization_id: shipment.organization_id)
    return if invalid_records(shipments: [shipment, *shipments])

    @scope = scope_for(record: @user)
    @shipments = Legacy::ShipmentDecorator.decorate_collection(shipments, context: { scope: @scope})
    @shipment = Legacy::ShipmentDecorator.new(shipment, context: { scope: @scope})
    @quotation = quotation
    @user = @shipment.user
    @user_profile = Profiles::ProfileService.fetch(user_id: @shipment.user_id)
    @organization = ::Organizations::Organization.current
    pdf_service = Pdf::Service.new(user: @user, organization: @organization)
    @quotes = pdf_service.quotes_with_trip_id(quotation: @quotation, shipments: @shipments)
    @org_theme = ::Organizations::ThemeDecorator.new(@organization.theme)
    @theme = @org_theme.legacy_format
    @email = email[/[^@]+/]
    @content = Legacy::Content.get_component('QuotePdf', ::Organizations.current_id)
    mot = @quotes.dig(0, 'mode_of_transport') || 'ocean'
    @mot_icon = URI.open(
      "https://assets.itsmycargo.com/assets/icons/mail/mail_#{mot}.png"
    ).read

    pdf_name = "quotation_#{@shipments.pluck(:imc_reference).join(',')}.pdf"
    document = pdf_service.quotation_pdf(quotation: @quotation)&.attachment
    attachments[pdf_name] = document if document.present?
    email_logo = @org_theme.email_logo
    attachments.inline['logo.png'] = email_logo.attached? ? email_logo&.download : ''
    attachments.inline['icon.png'] = @mot_icon

    mail(
      from: Mail::Address.new("no-reply@#{@organization.slug}.itsmycargo.shop")
                         .tap { |a| a.display_name = @org_theme.name }.format,
      reply_to: @org_theme.emails.dig('support', 'general'),
      to: mail_target_interceptor(@quotation.billing, email),
      subject: subject_line(shipment: @shipment, type: :quotation, references: @shipments.pluck(:imc_reference))
    ) do |format|
      format.html
      format.mjml
    end
  end

  def quotation_admin_email(quotation, shipment = nil) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    user_id = quotation&.user_id || shipment&.user_id
    @user = Users::User.find_by(id: user_id)
    @user_profile = Profiles::ProfileService.fetch(user_id: user_id)

    @shipments = quotation ? quotation.shipments : [shipment]
    @shipment = quotation ? Shipment.find(quotation.original_shipment_id) : shipment
    return if invalid_records(shipments: [@shipment, *@shipments])

    @quotation = quotation
    organization_id = (@user&.organization_id || @shipment&.organization_id)
    set_current_id(organization_id: organization_id)
    @scope = scope_for(record: @user)
    @shipments = Legacy::ShipmentDecorator.decorate_collection(@shipments, context: { scope: @scope})
    @shipment = Legacy::ShipmentDecorator.new(@shipment, context: { scope: @scope})
    @organization = ::Organizations::Organization.current
    @org_theme = ::Organizations::ThemeDecorator.new(@organization.theme)
    @theme = @org_theme.legacy_format

    pdf_service = Pdf::Service.new(user: @user, organization: @organization)
    @quotes = pdf_service.quotes_with_trip_id(quotation: @quotation, shipments: @shipments)
    @content = Legacy::Content.get_component('QuotePdf', @organization.id)
    pdf_name = "quotation_#{@shipments.pluck(:imc_reference).join(',')}.pdf"
    document = pdf_service.admin_quotation(quotation: @quotation, shipment: shipment)&.attachment
    attachments[pdf_name] = document if document.present?
    email_logo = @org_theme.email_logo
    billing = (quotation&.billing || shipment&.billing)
    attachments.inline['logo.png'] = email_logo.attached? ? email_logo&.download : ''
    mail(
      from: Mail::Address.new("no-reply@#{@organization.slug}.itsmycargo.shop")
                         .tap { |a| a.display_name = 'ItsMyCargo Quotation Tool' }.format,
      reply_to: Settings.emails.support,
      to: mail_target_interceptor(billing, @org_theme.email_for(:sales, @shipment.mode_of_transport)),
      subject: subject_line(shipment: @shipment, type: :quotation, references: @shipments.pluck(:imc_reference))
    ) do |format|
      format.html
      format.mjml
    end
  end

  private

  def generate_and_upload_quotation(quotes)
    quotation = Pdf::Handler.new(
      layout: 'pdfs/simple.pdf.html.erb',
      template: 'shipments/pdfs/quotations.pdf.erb',
      margin: { top: 15, bottom: 5, left: 8, right: 8 },
      shipment: @shipment,
      shipments: @shipments,
      quotation: @quotation,
      quotes: quotes,
      color: @theme['colors']['primary'],
      name: 'quotation',
      remarks: Legacy::Remark.where(organization_id: @organization.id).order(order: :asc),
      scope: scope_for(record: @user)
    )
    quotation.generate
  end

  def invalid_records(shipments:)
    shipments.any?(&:deleted?) || shipments.any?(&:destroyed?)
  end
end
