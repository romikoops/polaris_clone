class ShipmentMailer < ApplicationMailer
  default from: "ItsMyCargo Bookings <bookings@itsmycargo.com>"
  layout 'mailer'
  add_template_helper(ApplicationHelper)

  def tenant_notification(user, shipment)
    @user = user
    tenant = user.tenant
    @shipment = shipment

    attachments.inline['logo.png'] = open(tenant.theme["logoLarge"]).read

    mail(
      # to: tenant.emails["sales"].blank? ? "itsmycargodev@gmail.com" : tenant.emails["sales"], 
      # to: 'mailtests@itsmycargo.com',
      to: 'sa_sa_surf_@hotmail.com',
      subject: 'Your booking through ItsMyCargo'
    )
  end

  def shipper_notification(user, shipment)
    @user = user
    tenant = user.tenant
    @shipment = shipment

    attachments.inline['logo.png']       = open(tenant.theme["logoLarge"]).read
    attachments.inline['logo_small.png'] = open(tenant.theme["logoSmall"]).read

    mail(
      # to: user.email.blank? ? "itsmycargodev@gmail.com" : user.email, 
      # to: 'mailtests@itsmycargo.com',
      to: 'sa_sa_surf_@hotmail.com',
      subject: 'Your booking through ItsMyCargo'
    )
  end

  def shipper_confirmation(user, shipment)
    @user = user
    tenant = user.tenant
    @shipment = shipment
    
    attachments.inline['logo.png']       = open(tenant.theme["logoLarge"]).read
    attachments.inline['logo_small.png'] = open(tenant.theme["logoSmall"]).read
    
    bill_of_lading = generate_and_upload_bill_of_lading
    attachments[bill_of_lading.full_name] = open(bill_of_lading.path).read
    FileUtils.rm(bill_of_lading.path)

    mail(
      # to: user.email.blank? ? "itsmycargodev@gmail.com" : user.email, 
      # to: 'mailtests@itsmycargo.com',
      to: 'sa_sa_surf_@hotmail.com',
      subject: 'Your booking through ItsMyCargo'
    )
  end

  private 

  def generate_and_upload_bill_of_lading
    bill_of_lading = PdfHandler.new(
      layout:   "pdfs/simple.pdf.html.erb",
      template: "shipments/pdfs/bill_of_lading.pdf.html.erb",
      margin:   { top: 10, bottom: 5, left: 8, right: 8 },
      shipment: @shipment,
      name:     'bill_of_lading'
    )

    bill_of_lading.generate
    bill_of_lading.upload
  end
end
