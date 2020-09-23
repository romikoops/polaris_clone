# frozen_string_literal: true

class QuoteMailer < ApplicationMailer
  default from: 'ItsMyCargo Bookings <bookings@itsmycargo.com>'
  layout 'mailer'
  add_template_helper(ApplicationHelper)

  def new_quotation_email(quotation:, tender_ids:, shipment:, email:)
    set_current_id(organization_id: quotation.organization_id)
    return if invalid_records(shipments: [shipment])

    @quotation = quotation
    @shipment = shipment

    @user_profile = Profiles::ProfileService.fetch(user_id: user.id)
    @scope = scope_for(record: user)
    @quotes = pdf_service.tenders(quotation: @quotation, shipment: shipment, tender_ids: tender_ids)

    return if @quotes.empty?

    @org_theme = ::Organizations::ThemeDecorator.new(current_organization.theme)
    @email = email[/[^@]+/]
    @content = Legacy::Content.get_component('QuotePdf', ::Organizations.current_id)
    email_logo = @org_theme.email_logo

    attachments[pdf_name] = pdf_document if pdf_document.present?
    attachments.inline['logo.png'] = @org_theme.email_logo.attached? ? email_logo.download : ''
    attachments.inline['icon.png'] = mot_icon(mot)

    mail(
      from: from(display_name: @org_theme.name),
      reply_to: @org_theme.emails.dig('support', 'general'),
      to: mail_target_interceptor(shipment.billing, email),
      subject: subject_line(shipment: decorated_shipment, type: :quotation, references: tender_references)
    ) do |format|
      format.html { render 'quotation_email' }
      format.mjml { render 'quotation_email' }
    end
  end

  def new_quotation_admin_email(quotation:, shipment:)
    set_current_id(organization_id: quotation.organization_id)

    @shipment = Legacy::ShipmentDecorator.new(shipment, context: { scope: @scope})
    @quotation = quotation
    @user_profile = Profiles::ProfileService.fetch(user_id: user.id)
    return if invalid_records(shipments: [shipment])

    @scope = scope_for(record: user)
    @org_theme = ::Organizations::ThemeDecorator.new(current_organization.theme)
    pdf_service = Pdf::Service.new(user: user, organization: current_organization)
    @quotes = pdf_service.tenders(quotation: @quotation, shipment: shipment, tender_ids: @quotation.tenders.ids)
    @content = Legacy::Content.get_component('QuotePdf', current_organization.id)
    document = pdf_service.admin_quotation(quotation: @quotation, shipment: shipment, pdf_tenders: @quotes)&.attachment
    attachments[pdf_name] = document if document.present?
    email_logo = @org_theme.email_logo
    billing = @quotation&.billing
    attachments.inline['logo.png'] = email_logo.attached? ? email_logo&.download : ''
    mail(
      from: from(display_name: 'ItsMyCargo Quotation Tool'),
      reply_to: Settings.emails.support,
      to: mail_target_interceptor(billing, @org_theme.email_for(:sales, shipment.mode_of_transport)),
      subject: subject_line(shipment: @shipment, type: :quotation, references: tender_references)
    ) do |format|
      format.html { render 'quotation_admin_email' }
      format.mjml { render 'quotation_admin_email' }
    end
  end

  private

  def pdf_service
    @pdf_service ||= Pdf::Service.new(user: user, organization: current_organization)
  end

  def pdf_document
    @pdf_document ||=
      pdf_service.tenders_pdf(quotation: @quotation, shipment: @shipment, pdf_tenders: @quotes)&.attachment
  end

  def mot_icon(mot)
    URI.open(
      "https://assets.itsmycargo.com/assets/icons/mail/mail_#{mot}.png"
    ).read
  end

  def user
    @user ||= @quotation.user || default_user
  end

  def mot
    @quotes.dig(0, 'mode_of_transport') || 'ocean'
  end

  def decorated_shipment
    @decorated_shipment ||= Legacy::ShipmentDecorator.new(@shipment, context: { scope: @scope})
  end

  def tender_references
    @quotation.tenders.pluck(:imc_reference)
  end

  def pdf_name
    "quotation_#{tender_references.join(',')}.pdf"
  end

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
      scope: scope_for(record: user)
    )
    quotation.generate
  end

  def invalid_records(shipments:)
    shipments.any?(&:deleted?) || shipments.any?(&:destroyed?)
  end

  def from(display_name:)
    Mail::Address.new("no-reply@#{current_organization.slug}.itsmycargo.shop")
      .tap { |a| a.display_name = display_name }.format
  end

  def default_user
    @default_user ||= Organizations::User.new(organization: current_organization)
  end
end
