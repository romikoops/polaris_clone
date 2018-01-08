class Admin::ShipmentsController < ApplicationController
  include ShippingTools
  before_action :require_login_and_role_is_admin

  def index
    @documents = {}
    @requested_shipments = Shipment.where(status: "requested")
    @documents['requested_shipments'] = Document.get_documents_for_array(@requested_shipments)
    @open_shipments = Shipment.where(status: ["accepted", "in_progress"])
    @documents['open_shipments'] = Document.get_documents_for_array(@open_shipments)
    @finished_shipments = Shipment.where(status: ["declined", "finished"])
    @documents['finished_shipments'] = Document.get_documents_for_array(@finished_shipments)
    resp = {
      requested: @requested_shipments,
      open: @open_shipments,
      finished: @finished_shipments,
      documents: @documents
    }
    response_handler(resp)
  end
  def show
    @shipment = Shipment.find(params[:id])
    @cargo_items = @shipment.cargo_items
    @containers = @shipment.containers
    hs_codes = []
    @cargo_items.each do |ci|
      if ci && ci.hs_codes
        ci.hs_codes.each do |hs|
          hs_codes << hs
        end
      end
    end
    @containers.each do |cn|
      if cn && cn.hs_codes
        cn.hs_codes.each do |hs|
          hs_codes << hs
        end
      end
    end
    hsCodes = get_hs_code_hash(hs_codes)
    @shipment_contacts = @shipment.shipment_contacts
    @contacts = []
    @shipment_contacts.each do |sc|
      @contacts.push({contact: sc.contact, type: sc.contact_type, location: sc.contact.location})
    end
    @schedules = []
    @shipment.schedule_set.each do |ss|
      @schedules.push(Schedule.find(ss['id']))
    end
    @documents = []
    @shipment.documents.each do |doc|
      tmp = doc.as_json
      tmp["signed_url"] =  doc.get_signed_url
      @documents << tmp
    end
    resp = {shipment: @shipment, cargoItems: @cargo_items, containers: @containers, contacts: @contacts, documents: @documents, schedules: @schedules, hsCodes: hsCodes}
    response_handler(resp)
  end

  def email_action
    shipment = Shipment.find_by_uuid(params[:uuid])

    case params[:shipment_action]
    when "accept"
      shipment.accept!
      redirect_to admin_shipments_path
    when "decline"
      shipment.decline!
      redirect_to admin_shipments_path
    when "edit"
      redirect_to edit_admin_shipment_path(shipment)
    else
      raise "Unknown shipment editing option!"
    end
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
        # redirect_to admin_shipments_path
      when "decline"
        @shipment.decline!
        # redirect_to admin_shipments_path
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
     @documents = []
    @shipment.documents.each do |doc|
      tmp = doc.as_json
      tmp["signed_url"] =  doc.get_signed_url
      @documents << tmp
    end
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
