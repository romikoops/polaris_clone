class ShipmentMailerClientPreview < ActionMailer::Preview
  def shipper_notification
    @shipment = Tenant.find_by_subdomain('speedtrans').shipments.where(status: 'requested', load_type: 'cargo_item').last
    ShipmentMailer.shipper_notification(@shipment.user, @shipment)
  end
end