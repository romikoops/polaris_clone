# frozen_string_literal: true

class ShipmentMailerPreview < ActionMailer::Preview
  def tenant_notification
    @shipment = Tenant.find_by(subdomain: 'normanglobal').shipments.requested.last
    ShipmentMailer.tenant_notification(@shipment.user, @shipment)
  end

  def shipper_notification
    @shipment = Tenant.find_by(subdomain: 'normanglobal').shipments.requested.last
    ShipmentMailer.shipper_notification(@shipment.user, @shipment)
  end

  def shipper_confirmation
    @shipment = Shipment.open.last
    ShipmentMailer.shipper_confirmation(@shipment.user, @shipment)
  end
end
