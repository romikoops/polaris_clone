# frozen_string_literal: true

class QuoteMailer < ApplicationMailer
  default from: 'ItsMyCargo Bookings <bookings@itsmycargo.com>'
  layout 'mailer'
  add_template_helper(ApplicationHelper)

  def quotation_email(shipment, shipments, email, quotation, sandbox = nil) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    return if invalid_records(shipments: [shipment, *shipments])

    @shipments = shipments
    @shipment = shipment
    @quotation = quotation
    @user = @shipment.user
    @user_profile = ProfileTools.profile_for_user(legacy_user: @user)
    pdf_service = Pdf::Service.new(user: @user, tenant: @user.tenant)
    @quotes = pdf_service.quotes_with_trip_id(quotation: @quotation, shipments: @shipments)
    @tenant = Tenant.find(@user.tenant_id)
    @tenants_tenant = ::Tenants::Tenant.find_by(legacy_id: @user.tenant_id)
    @theme = ::Tenants::ThemeDecorator.new(@tenants_tenant.theme).legacy_format
    @email = email[/[^@]+/]
    @content = Legacy::Content.get_component('QuotePdf', @user.tenant.id)
    @scope = scope_for(record: @user, sandbox: sandbox)
    @mot_icon = URI.open(
      "https://assets.itsmycargo.com/assets/icons/mail/mail_#{@shipments.first.mode_of_transport}.png"
    ).read

    pdf_name = "quotation_#{@shipments.pluck(:imc_reference).join(',')}.pdf"
    document = pdf_service.quotation_pdf(quotation: @quotation)&.attachment
    attachments[pdf_name] = document if document.present?
    email_logo = @tenants_tenant.theme.email_logo
    attachments.inline['logo.png'] = email_logo.attached? ? email_logo&.download : ''
    attachments.inline['icon.png'] = @mot_icon

    mail(
      from: Mail::Address.new("no-reply@#{@tenants_tenant.slug}.itsmycargo.shop")
                         .tap { |a| a.display_name = @tenant.name }.format,
      reply_to: @tenant.emails.dig('support', 'general'),
      to: mail_target_interceptor(@user, email),
      subject: subject_line(shipment: @shipment, type: :quotation, references: @shipments.pluck(:imc_reference))
    ) do |format|
      format.html
      format.mjml
    end
  end

  def quotation_admin_email(quotation, shipment = nil, sandbox = nil) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @shipments = quotation ? quotation.shipments : [shipment]
    @shipment = quotation ? Shipment.find(quotation.original_shipment_id) : shipment
    return if invalid_records(shipments: [@shipment, *@shipments])

    @quotation = quotation
    @tenant = Tenant.find(@shipment.tenant_id)
    @tenants_tenant = ::Tenants::Tenant.find_by(legacy_id: @shipment.tenant_id)
    @theme = ::Tenants::ThemeDecorator.new(@tenants_tenant.theme).legacy_format
    @user = (quotation&.user || shipment&.user)
    @user_profile = ProfileTools.profile_for_user(legacy_user: @user)

    pdf_service = Pdf::Service.new(user: @user, tenant: @tenant)
    @quotes = pdf_service.quotes_with_trip_id(quotation: @quotation, shipments: @shipments)
    @content = Legacy::Content.get_component('QuotePdf', @user.tenant.id)
    @scope = scope_for(record: @user, sandbox: sandbox)
    pdf_name = "quotation_#{@shipments.pluck(:imc_reference).join(',')}.pdf"
    document = pdf_service.admin_quotation(quotation: @quotation, shipment: shipment)&.attachment
    attachments[pdf_name] = document if document.present?
    email_logo = @tenants_tenant.theme.email_logo
    attachments.inline['logo.png'] = email_logo.attached? ? email_logo&.download : ''
    mail(
      from: Mail::Address.new("no-reply@#{@tenants_tenant.slug}.itsmycargo.shop")
                         .tap { |a| a.display_name = 'ItsMyCargo Quotation Tool' }.format,
      reply_to: Settings.emails.support,
      to: mail_target_interceptor(@user, @tenant.email_for(:sales, @shipment.mode_of_transport)),
      subject: subject_line(shipment: @shipment, type: :quotation, references: @shipments.pluck(:imc_reference))
    ) do |format|
      format.html
      format.mjml
    end
  end

  private

  def generate_and_upload_quotation(quotes, sandbox = nil)
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
      remarks: Legacy::Remark.where(tenant_id: @user.tenant_id, sandbox: sandbox).order(order: :asc),
      scope: scope_for(record: @user, sandbox: sandbox)
    )
    quotation.generate
  end

  def invalid_records(shipments:)
    shipments.any?(&:deleted?)
  end
end
