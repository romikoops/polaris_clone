# frozen_string_literal: true

class QuoteMailer < ApplicationMailer
  default from: 'ItsMyCargo Bookings <bookings@itsmycargo.com>'
  layout 'mailer'
  add_template_helper(ApplicationHelper)

  def quotation_email(shipment, shipments, email, quotation) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @shipments = shipments
    @shipment = shipment
    @quotation = quotation
    @quotes = @shipments.map(&:selected_offer)
    @user = @shipment.user
    @theme = @user.tenant.theme
    @email = email[/[^@]+/]
    @content = Content.get_component('QuotePdf', @user.tenant.id)

    @mot_icon = URI.open(
      "https://assets.itsmycargo.com/assets/icons/mail/mail_#{@shipment.mode_of_transport}.png"
    ).read
    quotation = generate_and_upload_quotation(@quotes)
    @document = Document.create!(
      shipment: shipment,
      text: "quotation_#{shipment.imc_reference}",
      doc_type: 'quotation',
      user: @user,
      tenant: @user.tenant,
      file: {
        io: StringIO.new(quotation),
        filename: "quotation_#{shipment.imc_reference}.pdf",
        content_type: 'application/pdf'
      }
    )
    pdf_name = "quotation_#{@shipment.imc_reference}.pdf"
    attachments.inline['logo.png'] = URI.open(
      "https://assets.itsmycargo.com/assets/logos/emails/#{@user.tenant.subdomain}_white.png"
    ).read
    attachments.inline['icon.png'] = @mot_icon
    attachments.inline[pdf_name] = quotation

    mail(
      from: Mail::Address.new("no-reply@#{@user.tenant.subdomain}.#{Settings.emails.domain}")
                         .tap { |a| a.display_name = @user.tenant.name }.format,
      reply_to: @user.tenant.emails.dig('support', 'general'),
      to: mail_target_interceptor(@user, email),
      subject: "Quotation for #{@shipment.imc_reference}"
    ) do |format|
      format.html
      format.mjml
    end
  end

  def quotation_admin_email(shipment, shipments, quotation) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @shipments = shipments
    @shipment = shipment
    @quotation = quotation
    @quotes = @shipments.map(&:selected_offer)
    @user = @shipment.user
    @theme = @user.tenant.theme
    @content = Content.get_component('QuotePdf', @user.tenant.id)

    quotation = generate_and_upload_quotation(@quotes)
    @document = Document.create!(
      shipment: shipment,
      text: "quotation_#{shipment.imc_reference}",
      doc_type: 'quotation',
      user: @user,
      tenant: @user.tenant,
      file: {
        io: StringIO.new(quotation),
        filename: "quotation_#{shipment.imc_reference}.pdf",
        content_type: 'application/pdf'
      }
    )
    pdf_name = "quotation_#{@shipment.imc_reference}.pdf"
    attachments.inline['logo.png'] = URI.open(@theme['logoLarge']).read
    attachments.inline[pdf_name] = quotation

    mail(
      from: Mail::Address.new("no-reply@#{@user.tenant.subdomain}.#{Settings.emails.domain}")
                         .tap { |a| a.display_name = 'ItsMyCargo Quotation Tool' }.format,
      reply_to: Settings.emails.support,
      to: mail_target_interceptor(@user, @user.tenant.email_for(:sales, shipment.mode_of_transport)),
      subject: "Quotation for #{@shipment.imc_reference}"
    ) do |format|
      format.html
      format.mjml
    end
  end

  private

  def generate_and_upload_quotation(quotes)
    quotation = PdfHandler.new(
      layout: 'pdfs/simple.pdf.html.erb',
      template: 'shipments/pdfs/quotations.pdf.erb',
      margin: { top: 15, bottom: 5, left: 8, right: 8 },
      shipment: @shipment,
      shipments: @shipments,
      quotation: @quotation,
      quotes: quotes,
      color: @user.tenant.theme['colors']['primary'],
      name: 'quotation',
      remarks: Remark.where(tenant_id: @user.tenant_id).order(order: :asc)
    )
    quotation.generate
  end
end
