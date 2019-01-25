# frozen_string_literal: true

class ShipmentMailerPreview < ActionMailer::Preview
  def tenant_notification
    @shipment = Tenant.normanglobal.shipments.requested.last
    ShipmentMailer.tenant_notification(@shipment.user, @shipment)
  end

  def shipper_notification
<<<<<<< HEAD
    @shipment = Tenant.normanglobal.shipments.requested.last
=======
    @shipment = Shipment.where(status: 'requested', load_type: 'cargo_item').last
>>>>>>> 7c9d39d3d... IMC-1212 - conflicts resolved
    ShipmentMailer.shipper_notification(@shipment.user, @shipment)
  end

  def shipper_confirmation
    @shipment = Shipment.open.last
    ShipmentMailer.shipper_confirmation(@shipment.user, @shipment)
  end
end
