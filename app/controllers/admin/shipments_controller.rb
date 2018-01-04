class Admin::ShipmentsController < ApplicationController
  before_action :require_login_and_role_is_admin
  include ShippingTools

  def index
    @documents = {}
    @requested_shipments = Shipment.where(status: "requested")
    @documents['requested_shipments'] = Document.get_documents_for_array(@requested_shipments)
    @open_shipments = Shipment.where(status: ["accepted", "in_progress"])
    @documents['open_shipments'] = Document.get_documents_for_array(@open_shipments)
    @finished_shipments = Shipment.where(status: ["declined", "finished"])
    @documents['finished_shipments'] = Document.get_documents_for_array(@finished_shipments)
    resp = {
      requested: {documents: @documents['requested_shipments'], shipments: @requested_shipments},
      open: {documents: @documents['open_shipments'], shipments: @open_shipments},
      finished: {documents: @documents['finished_shipments'], shipments: @finished_shipments}
    }
    response_handler(resp)
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

  def edit
    @shipment = Shipment.find(params[:id])
    @containers = Container.where(shipment_id: @shipment.id)
    @container_descriptions = CONTAINER_DESCRIPTIONS.invert
    @all_hubs = Location.all_hubs_prepared
  end

  def update
    @shipment = Shipment.find(params[:id])
    if params[:shipment_action] # This happens when accept or decline buttons are used
      case params[:shipment_action]
      when "accept"
        @shipment.accept!
        booking_confirmation_email(current_user, shipment)
        send_booking_emails(shipment)
      when "decline"
        @shipment.decline!
      else
        raise "Unknown action!"
      end
    else # This happens when shipment is edited with edit form
      if @shipment.update(shipment_params)
        # redirect_to admin_shipments_path
      else
        # render 'edit'
      end
    end
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

  private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name == "admin"
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end

  def shipment_params
    params.require(:shipment).permit(:total_price, :planned_pickup_date,:origin_id, :destination_id)
  end
end
