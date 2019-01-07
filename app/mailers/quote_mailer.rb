# frozen_string_literal: true

class QuoteMailer < ApplicationMailer
  default from: 'ItsMyCargo Bookings <bookings@itsmycargo.com>'
  layout 'mailer'
  add_template_helper(ApplicationHelper)

  def quotation_email(shipment, shipments, email, quotation)
    @shipments = shipments
    @shipment = shipment
    @quotation = quotation
    @quotes = @shipments.map(&:selected_offer)
    @user = @shipment.user
    tenant = @user.tenant
    @theme = tenant.theme
    @email = email[/[^@]+/]

    quotation = generate_and_upload_quotation(@quotes)
    @document = Document.create!(
      shipment: shipment,
      # quotation: quotation, # TODO: Implement proper quotation tools
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
    attachments.inline['logo.png'] = URI.open(tenant.theme['logoLarge']).read
    attachments.inline[pdf_name] = quotation

    mail(
      from: tenant.emails.dig('support','general'),
      to: mail_target_interceptor(@user, email),
      subject: "Quotation for #{@shipment.imc_reference}"
    ) do |format|
      format.html
      format.mjml
    end
  end

  private

  def generate_and_upload_quotation(quotes)
    quotation = PdfHandler.new(
      layout:      'pdfs/simple.pdf.html.erb',
      template:    'shipments/pdfs/quotations.pdf.erb',
      margin:      { top: 15, bottom: 5, left: 8, right: 8 },
      shipment:    @shipment,
      shipments:   @shipments,
      quotation:   @quotation,
      quotes:      quotes,
      color:       @user.tenant.theme['colors']['primary'],
      name:        'quotation',
      remarks:    Remark.where(tenant_id: @user.tenant_id)
    )
    quotation.generate
  end
end
