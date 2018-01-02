class ShipmentsController < ApplicationController
  include ShippingTools

  skip_before_action :require_non_guest_authentication!, except: [:finish_booking, :upload_document]

  def index
    @shipper = current_user

    @requested_shipments = @shipper.shipments.where(status: "requested")
    @open_shipments = @shipper.shipments.where(status: ["accepted", "in_progress"])
    @finished_shipments = @shipper.shipments.where(status: ["declined", "finished"])
    resp = {
      requested: @requested_shipments,
      open: @open_shipments,
      finished: @finished_shipments
    }
    response_handler(resp)
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
      create_document(params[:file], @shipment, params[:type], current_user)
    end
  end

  def reuse_booking_data
    reuse_shipment_data(params, session, 'openlcl')
  end

  def show
    @shipment = Shipment.find(params[:id])
    @cargo_items = @shipment.cargo_items
    @containers = @shipment.containers
    @shipment_contacts = @shipment.shipment_contacts
    @contacts = []
    @shipment_contacts.each do |sc|
      @contacts.push({contact: sc.contact, type: sc.contact_type, location: sc.contact.location})
    end
    @schedules = []
    @shipment.schedule_set.each do |ss|
      @schedules.push(Schedule.find(ss['id']))
    end
    @documents = @shipment.documents
    resp = {shipment: @shipment, cargoItems: @cargo_items, containers: @containers, contacts: @contacts, documents: @documents, schedules: @schedules}
    response_handler(resp)
  end

  def create
    resp = new_shipment(session, params[:type])
    response_handler(resp)
  end

  def get_offer
    resp = get_shipment_offer(session, params, 'openlcl')
    response_handler(resp)
  end

  def finish_booking
    resp = finish_shipment_booking(params)
    response_handler(resp)
  end

  def update
    resp = update_shipment(session, params)
    response_handler(resp)
  end

  def get_shipper_pdf
    get_shipment_pdf(params)
  end

  private

  def forwarder_notification_email(user, shipment)
    ShipmentMailer.forwarder_notification(user, shipment).deliver_now
  end
end
