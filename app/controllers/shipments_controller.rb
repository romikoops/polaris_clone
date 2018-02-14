class ShipmentsController < ApplicationController
  include ShippingTools
  include MongoTools

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

  def test_email
    tenant_notification_email(current_user, Shipment.first)
  end
  # Uploads document and returns Document item
  def upload_document
    @shipment = Shipment.find(params[:shipment_id])
    @doc
    if params[:file]
      @doc = create_document(params[:file], @shipment, params[:type], current_user)
      tmp = @doc.as_json
      tmp["signed_url"] = @doc.get_signed_url
    end
    response_handler(tmp)
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
    @schedules = @shipment.schedule_set
    @documents = []
    @shipment.documents.each do |doc|
      tmp = doc.as_json
      tmp["signed_url"] =  doc.get_signed_url
      @documents << tmp
    end
    resp = {shipment: @shipment, cargoItems: @cargo_items, containers: @containers, contacts: @contacts, documents: @documents, schedules: @schedules}
    response_handler(resp)
  end

  def create
    resp = new_shipment(params[:loadType].underscore)
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
    
    shipment = resp[:shipment]
    tenant_notification_email(shipment.shipper, shipment)
    shipper_notification_email(shipment.shipper, shipment)

    response_handler(resp)
  end

  def get_shipper_pdf
    get_shipment_pdf(params)
  end
end
