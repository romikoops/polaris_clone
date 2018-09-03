class ShipmentMailerClientPreview < ActionMailer::Preview
  def shipper_notification
    @shipment = Shipment.where(status: 'requested').last
    ShipmentMailer.shipper_notification(@shipment.user, @shipment)
  end
end