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

    generate_and_upload_quotation(@quotes)
    pdf_name = "quotation_#{@shipment.imc_reference}.pdf"
    attachments.inline['logo.png'] = URI.open(tenant.theme['logoLarge']).read
    attachments.inline[pdf_name] = File.read('tmp/' + pdf_name)
    mail(
      to: email,
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
      name:        'quotation'
    )
    quotation.generate
    quotation.upload_quotes
  end
end
