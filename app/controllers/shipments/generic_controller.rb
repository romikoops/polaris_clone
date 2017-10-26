class Shipments::GenericController < ApplicationController
  before_action :require_login_and_correct_id, except: [:test_email]

  layout 'dashboard'

  def index
    @shipper = current_user

    @requested_shipments = @shipper.shipments.where(status: "requested")
    @open_shipments = @shipper.shipments.where(status: ["accepted", "in_progress"])
    @finished_shipments = @shipper.shipments.where(status: ["declined", "finished"])
  end

  def new
    
  end

  def reuse_booking_data
    shipment = Shipment.find(params[:generic_id])
    if shipment.is_lcl?
      redirect_to user_shipments_lcl_reuse_booking_path(lcl_id: shipment.id)
    else
      redirect_to user_shipments_fcl_reuse_booking_path(fcl_id: shipment.id)
    end
  end

  def test_email
    forwarder_notification_email(current_user, Shipment.first)
  end

  private

  def forwarder_notification_email(user, shipment)
    ShipmentMailer.forwarder_notification(user, shipment).deliver_now
  end

  def require_login_and_correct_id
    unless user_signed_in? && current_user.id.to_s == params[:user_id]
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end
