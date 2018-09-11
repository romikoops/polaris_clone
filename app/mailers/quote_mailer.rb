# frozen_string_literal: true

class QuoteMailer < ApplicationMailer
  default from: "ItsMyCargo Bookings <bookings@itsmycargo.com>"
  layout "mailer"
  add_template_helper(ApplicationHelper)

  TESTING_EMAIL = "angelica.vanni@itsmycargo.com"

  def quotation_email(shipment, shipments, email)
    @shipments = shipments
    @shipment = shipment
    @quotes = @shipments.map do |quoted_shipment|
      quoted_shipment.selected_offer
    end
    @user = @shipment.user
    tenant = @user.tenant
    @email = email[/[^@]+/]
    base_url =
      case Rails.env
      when "production"  then "http://#{@shipment.tenant.subdomain}.itsmycargo.com/"
      when "development" then "http://localhost:8080/"
      when "test"        then "http://localhost:8080/"
      end
          
    generate_and_upload_quotation(@quotes)
    pdf_name = "quotation_#{@shipment.imc_reference}.pdf"
    attachments.inline["logo.png"] = URI.open(tenant.theme["logoLarge"]).read
    attachments.inline[pdf_name] = File.read("tmp/" + pdf_name)
    mail(
      # to:      tenant.email_for(:sales, shipment.mode_of_transport),
      # to: email,
      # bcc:     "bookings@itsmycargo.com",
      subject: "Quotation for #{@shipments.first.origin_hub.name} - #{@shipments.first.destination_hub.name}"
    ) do |format|
      format.html
      format.mjml
    end
  end

  private

  def generate_and_upload_quotation(quotes)
    quotation = PdfHandler.new(
      layout:      "pdfs/simple.pdf.html.erb",
      template:    "shipments/pdfs/quotations.pdf.erb",
      margin:      { top: 15, bottom: 5, left: 8, right: 8 },
      shipment:    @shipment,
      shipments:   @shipments,
      quotes:      quotes,
      name:        "quotation"
    )
    quotation.generate
    quotation.upload_quotes
  end
end
