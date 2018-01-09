class ShipmentMailer < ApplicationMailer
  default from: "ItsMyCargo Bookings <bookings@itsmycargo.com>"
  layout 'mailer'
  add_template_helper(ApplicationHelper)

  def forwarder_notification(user, shipment)
    @user = user
    @shipment = shipment
    attachments.inline['logo.png'] = File.read("#{Rails.root}/client/app/assets/images/logos/logo_black.png")
    
    mail(to: user.email.blank? ? "itsmycargodev@gmail.com" : user.email, subject: 'Your booking through ItsMyCargo')
  end

  def booking_confirmation(user, shipment)
    @user = user
    @shipment = shipment
    attachments.inline['logo.png'] = File.read("#{Rails.root}/client/app/assets/images/logos/logo_black.png")
    attachments.inline['logo_small.png'] = File.read("#{Rails.root}/client/app/assets/images/logos/logo_black_small.png")
    mail(to: user.email.blank? ? "itsmycargodev@gmail.com" : user.email, subject: 'Your booking through ItsMyCargo')
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
end
