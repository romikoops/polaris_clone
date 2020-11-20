# frozen_string_literal: true

class ShipmentMailerPreview < ActionMailer::Preview
  def tenant_notification
    @organization = Organizations::Organization.find_by(slug: "demo")
    @shipment = Legacy::Shipment.where(organization: @organization).requested.last
    user = Users::User.find(@shipment.user_id)
    ShipmentMailer.tenant_notification(user, @shipment)
  end

  def shipper_notification
    @organization = Organizations::Organization.find_by(slug: "demo")
    @shipment = Legacy::Shipment.where(organization: @organization).requested.last
    user = Users::User.find(@shipment.user_id)
    ShipmentMailer.shipper_notification(user, @shipment)
  end

  def shipper_confirmation
    @shipment = Shipment.open.last
    ShipmentMailer.shipper_confirmation(@shipment.user, @shipment)
  end
end
