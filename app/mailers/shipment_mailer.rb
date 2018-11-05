# frozen_string_literal: true

class ShipmentMailer < ApplicationMailer
  default from: 'ItsMyCargo Bookings <bookings@itsmycargo.com>'
  layout 'mailer'
  add_template_helper(ApplicationHelper)

  TESTING_EMAIL = 'warwick@itsmycargo.com'

  def tenant_notification(user, shipment)
    @user = user
    tenant = user.tenant
    @shipment = shipment
    base_url =
      case Rails.env
      when 'production'  then "http://#{@shipment.tenant.subdomain}.itsmycargo.com/"
      when 'development' then 'http://localhost:8080/'
      when 'test'        then 'http://localhost:8080/'
      end

    @redirects_base_url = base_url + "redirects/shipments/#{@shipment.id}?action="

    create_pdf_attachment(@shipment)
    attachments.inline['logo.png'] = URI.open(tenant.theme['logoLarge']).read
    mail_options = {
      to: tenant.email_for(:sales, shipment.mode_of_transport),
      # to: TESTING_EMAIL,
      bcc: 'warwick@itsmycargo.com',
      subject: 'Your booking through ItsMyCargo'
    }

    mail(mail_options, &:html)
  end

  def shipper_notification(user, shipment)
    @user = user
    tenant = user.tenant
    @shipment = shipment

    create_pdf_attachment(@shipment)
    attachments.inline['logo.png']       = URI.open(tenant.theme['logoLarge']).read
    attachments.inline['logo_small.png'] = URI.try(:open, tenant.theme['logoSmall']).try(:read)
    mail_options = {
      to: user.email.blank? ? 'itsmycargodev@gmail.com' : user.email,
      # to: TESTING_EMAIL,
      bcc: ['bookingemails@itsmycargo.com', 'warwick@itsmycargo.com'],
      subject: 'Your booking through ItsMyCargo'
    }

    mail(mail_options, &:html)
  end

  def shipper_confirmation(user, shipment)
    @user = user
    tenant = user.tenant
    @shipment = shipment

    create_pdf_attachment(@shipment)
    attachments.inline['logo.png']       = URI.open(tenant.theme['logoLarge']).read
    attachments.inline['logo_small.png'] = try(:open, tenant.theme['logoSmall']).try(:read)
    mail_options = {
      to: user.email.blank? ? 'itsmycargodev@gmail.com' : user.email,
      # to: TESTING_EMAIL,
      bcc: ['bookingemails@itsmycargo.com', 'warwick@itsmycargo.com'],
      subject: 'Your booking through ItsMyCargo'
    }

    mail(mail_options, &:html)
  end

  private

  def generate_and_upload_bill_of_lading
    bill_of_lading = PdfHandler.new(
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
    pdf = ShippingTools.generate_shipment_pdf(shipment: shipment)
    attachments.inline["shipment_#{shipment.imc_reference}.pdf"] = pdf
  end
end
