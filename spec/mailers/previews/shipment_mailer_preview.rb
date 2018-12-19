# frozen_string_literal: true

class ShipmentMailerPreview < ActionMailer::Preview
  def tenant_notification
    @shipment = Shipment.where(status: 'requested', tenant_id: 41).last
    ShipmentMailer.tenant_notification(@shipment.user, @shipment)
  end

  def shipper_notification
    @shipment = Shipment.where(status: 'requested').last
    ShipmentMailer.shipper_notification(@shipment.user, @shipment)
  end
end
