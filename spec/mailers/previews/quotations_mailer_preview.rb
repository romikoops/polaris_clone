class ShipmentMailerClientPreview < ActionMailer::Preview
  def shipper_notification
    @shipment = Shipment.where(status: 'requested').last
    QuotationMailer.shipper_notification(@shipment.user, @shipment, )
  end
end