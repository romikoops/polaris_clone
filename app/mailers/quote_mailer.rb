# frozen_string_literal: true

class QuoteMailer < ApplicationMailer
  default from: "ItsMyCargo Bookings <bookings@itsmycargo.com>"
  layout "mailer"
  add_template_helper(ApplicationHelper)

  TESTING_EMAIL = "angelica.vanni@itsmycargo.com"

  def quotation_email(user, shipment)
    @user = user
    tenant = user.tenant
    @shipment = shipment
    # @quote = @shipment.quote
    base_url =
      case Rails.env
      when "production"  then "http://#{@shipment.tenant.subdomain}.itsmycargo.com/"
      when "development" then "http://localhost:8080/"
      when "test"        then "http://localhost:8080/"
      end

    # @redirects_base_url = base_url + "redirects/shipments/#{@shipment.id}?action="

    attachments.inline["logo.png"] = URI.open(tenant.theme["logoLarge"]).read

    mail(
      # to:      tenant.email_for(:sales, shipment.mode_of_transport),
      to: TESTING_EMAIL,
      # bcc:     "bookings@itsmycargo.com",
      subject: "Quotation for #{@shipment.orgin_hub.name} - #{@shipment.destination_hub.name}"
    ) do |format|
      format.html
      format.mjml
    end
  end

  private

  def generate_and_upload_quotation(quotes)
    quotation = PdfHandler.new(
      layout:   "pdfs/simple.pdf.html.erb",
      template: "shipments/pdfs/quotations.pdf.erb",
      margin:   { top: 10, bottom: 5, left: 8, right: 8 },
      shipment: @shipment,
      quotes:   quotes,
      name:     "quotation"
    )

    quotation.generate
    quotation.upload
  end
end
