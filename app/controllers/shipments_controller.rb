class ShipmentsController < ApplicationController
  before_action :require_login_and_correct_id, except: [:test_email]

  include ShippingTools
  include Response

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

  def upload_document
    @shipment = Shipment.find(params[:shipment_id])
    if params[:file]
      create_document(params[:file], @shipment, params[:type])
    end
  end

  def reuse_booking_data
    reuse_shipment_data(params, session, 'openlcl')
  end

  def show
    resp = Shipment.find(params[:shipment_id])
    json_response(resp, 200)
  end

  def create
    resp = new_shipment(session, params[:type])
    if resp[:error]
      json_response(resp, 400)
    else
      json_response(resp, 200)
    end
  end

  def get_offer
    resp = get_shipment_offer(session, params, 'openlcl')
    byebug
    response_handler(resp)
  end

  def finish_booking
    resp = finish_shipment_booking(params)
    json_response(resp, 200)
  end

  def update
    resp = update_shipment(session, params)
    json_response(resp, 200)
  end

  def get_shipper_pdf
    get_shipment_pdf(params)
  end

  private

  def require_login_and_correct_id
    unless user_signed_in?
      json_response({error: "You are not signed in"}, 500)
    end
  end

  def forwarder_notification_email(user, shipment)
    ShipmentMailer.forwarder_notification(user, shipment).deliver_now
  end
end
