# frozen_string_literal: true

class QuoteMailer < ApplicationMailer
  default from: 'ItsMyCargo Bookings <bookings@itsmycargo.com>'
  layout 'mailer'
  add_template_helper(ApplicationHelper)

  def new_quotation_email(quotation:, tender_ids:, shipment:, email:)
    set_current_id(organization_id: quotation.organization_id)

    @shipment = Legacy::ShipmentDecorator.new(shipment, context: { scope: @scope})
    @quotation = quotation
    organization_variables
    @pdf_service = Pdf::Quotation::Client.new(quotation: quotation, tender_ids: tender_ids)
    @quotes = @pdf_service.decorated_tenders
    @email = email[/[^@]+/]
    @content = Legacy::Content.get_component('QuotePdf', ::Organizations.current_id)

    add_attachments

    mail(
      from: from(display_name: @org_theme.name),
      reply_to: @org_theme.emails.dig('support', 'general'),
      to: mail_target_interceptor(shipment.billing, email),
      subject: subject_line(type: :quotation, references: tender_references, quotation: decorated_quotation)
    ) do |format|
      format.html { render 'quotation_email' }
      format.mjml { render 'quotation_email' }
    end
  end

  def new_quotation_admin_email(quotation:, shipment:)
    set_current_id(organization_id: quotation.organization_id)

    @quotation = quotation
    organization_variables
    @pdf_service = Pdf::Quotation::Admin.new(quotation: @quotation)
    @quotes = @pdf_service.decorated_tenders
    @content = Legacy::Content.get_component('QuotePdf', current_organization.id)
    add_attachments

    mail(
      from: from(display_name: 'ItsMyCargo Quotation Tool'),
      reply_to: Settings.emails.support,
      to: mail_target_interceptor(@quotation.billing, @org_theme.email_for(:sales, shipment.mode_of_transport)),
      subject: subject_line(type: :quotation, references: tender_references, quotation: decorated_quotation)
    ) do |format|
      format.html { render 'quotation_admin_email' }
      format.mjml { render 'quotation_admin_email' }
    end
  end

  private

  def organization_variables
    @user_profile = Profiles::ProfileService.fetch(user_id: user.id)
    @scope = scope_for(record: user)
    @org_theme = ::Organizations::ThemeDecorator.new(current_organization.theme)
  end

  def add_attachments
    attachments[pdf_name] = pdf_document if pdf_document.present?
    attachments.inline['logo.png'] = @org_theme.email_logo.attached? ? email_logo.download : ''
    attachments.inline['icon.png'] = mot_icon(mot)
  end

  def pdf_document
    @pdf_document ||= @pdf_service.attachment
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
    @quotes.first.mode_of_transport || 'ocean'
  end

  def decorated_shipment
    @decorated_shipment ||= Legacy::ShipmentDecorator.new(@shipment, context: { scope: @scope})
  end

  def decorated_quotation
    @decorated_quotation ||= QuotationDecorator.new(@quotation)
  end

  def tender_references
    @quotation.tenders.pluck(:imc_reference)
  end

  def pdf_name
    "quotation_#{tender_references.join(',')}.pdf"
  end

  def from(display_name:)
    Mail::Address.new("no-reply@#{current_organization.slug}.itsmycargo.shop")
      .tap { |a| a.display_name = display_name }.format
  end

  def default_user
    @default_user ||= Organizations::User.new(organization: current_organization)
  end
end
