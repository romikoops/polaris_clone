class ShipmentMailerPreview < ActionMailer::Preview
  def tenant_notification
    @shipment = Shipment.where(status: 'requested').last
    ShipmentMailer.tenant_notification(@shipment.user, @shipment)
  end
  def shipper_notification
    @shipment = Shipment.find_by_imc_reference('0312G1800001')
    # @shipment = Shipment.where(status: 'requested').last
    ShipmentMailer.shipper_notification(@shipment.user, @shipment)
  end
end