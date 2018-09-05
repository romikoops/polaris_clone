class ShipmentMailerPreview < ActionMailer::Preview
  def tenant_notification
    @tenant = Tenant.saco
    @shipment = @tenant.shipments.where(status: 'requested').last
    ShipmentMailer.tenant_notification(@shipment.user, @shipment)
  end
  def shipper_notification
    @tenant = Tenant.saco
    @shipment = @tenant.shipments.where(status: 'requested').last
    ShipmentMailer.shipper_notification(@shipment.user, @shipment)
  end
end