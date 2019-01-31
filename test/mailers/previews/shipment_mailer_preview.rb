class ShipmentMailerPreview < ActionMailer::Preview
  def tenant_notification
    @shipment = Shipment.where(status: 'requested').first
    ShipmentMailer.tenant_notification(@shipment.user, @shipment)
  end
end