# frozen_string_literal: true

class ShipmentMailerPreview < ActionMailer::Preview
  def tenant_notification
    @shipment = Tenant.normanglobal.shipments.requested.last
    ShipmentMailer.tenant_notification(@shipment.user, @shipment)
  end

  def shipper_notification
    @shipment = Tenant.normanglobal.shipments.requested.last
    ShipmentMailer.shipper_notification(@shipment.user, @shipment)
  end
end
