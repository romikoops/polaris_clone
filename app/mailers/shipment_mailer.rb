class ShipmentMailer < ApplicationMailer
  default from: "ItsMyCargo Bookings <bookings@itsmycargo.com>"
  layout 'mailer'
  add_template_helper(ApplicationHelper)

  def tenant_notification(user, shipment)
    @user = user
    tenant = user.tenant
    @shipment = shipment
    @eta = find_eta

    attachments.inline['logo.png'] = open(tenant.theme["logoLarge"]).read

    mail(
      to: tenant.emails["sales"].blank? ? "itsmycargodev@gmail.com" : tenant.emails["sales"], 
      subject: 'Your booking through ItsMyCargo'
    )
  end

  def shipper_notification(user, shipment)
    @user = user
    tenant = user.tenant
    @shipment = shipment
    @eta = find_eta

    attachments.inline['logo.png']       = open(tenant.theme["logoLarge"]).read
    attachments.inline['logo_small.png'] = open(tenant.theme["logoSmall"]).read

    mail(
      to: user.email.blank? ? "itsmycargodev@gmail.com" : user.email, 
      subject: 'Your booking through ItsMyCargo'
    )
  end

  def shipper_confirmation(user, shipment, filename, file)
    @user = user
    tenant = user.tenant
    @shipment = shipment
    @eta = find_eta

    attachments.inline['logo.png']       = open(tenant.theme["logoLarge"]).read
    attachments.inline['logo_small.png'] = open(tenant.theme["logoSmall"]).read
    attachments[filename] = file

    mail(
      to: user.email.blank? ? "itsmycargodev@gmail.com" : user.email, 
      subject: 'Your booking through ItsMyCargo'
    )
  end

  def summary_mail_shipper(shipment, filename, file)
    @shipment = shipment
    attachments[filename] = file
    mail(to: shipment.shipper.email, subject: 'Your booking through ItsMyCargo')
  end

  def summary_mail_trucker(shipment, filename, file)
    @shipment = shipment
    attachments[filename] = file
    mail(to: shipment.trucker.email, subject: 'Your booking through ItsMyCargo')
  end

  def summary_mail_consolidator(shipment, filename, file)
    @shipment = shipment
    attachments[filename] = file
    mail(to: shipment.consolidator.email, subject: 'Your booking through ItsMyCargo')
  end

  def summary_mail_receiver(shipment, filename, file)
    @shipment = shipment
    attachments[filename] = file
    mail(to: shipment.receiver.email, subject: 'Your booking through ItsMyCargo')
  end

  private

  def find_eta
    Schedule.find(@shipment.schedule_set.last["id"]).eta
  end
end
