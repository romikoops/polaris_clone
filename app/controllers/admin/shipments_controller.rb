class Admin::ShipmentsController < ApplicationController
  before_action :require_login_and_role_is_admin
  include ShippingTools
  include NotificationTools

  def index
    @documents = {}
    @requested_shipments = Shipment.where(status: "requested", tenant_id: current_user.tenant_id)
    @documents['requested_shipments'] = Document.get_documents_for_array(@requested_shipments)
    @open_shipments = Shipment.where(status: ["accepted", "in_progress", "confirmed"], tenant_id: current_user.tenant_id)
    @documents['open_shipments'] = Document.get_documents_for_array(@open_shipments)
    @finished_shipments = Shipment.where(status: ["declined", "finished"], tenant_id: current_user.tenant_id)
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
    cargo_item_types = {}

    @cargo_items.each do |ci|
      if ci && ci.hs_codes
        ci.hs_codes.each do |hs|
          hs_codes << hs
        end
      end
      cargo_item_types[ci.cargo_item_type_id] = CargoItemType.find(ci.cargo_item_type_id)
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
    @schedules = @shipment.schedule_set
    @documents = []
    @shipment.documents.each do |doc|
      tmp = doc.as_json
      tmp["signed_url"] =  doc.get_signed_url
      @documents << tmp
    end
    locations = {origin: @shipment.origin, destination: @shipment.destination}
    p @shipment.id
    resp = {shipment: @shipment, cargoItems: @cargo_items, containers: @containers, contacts: @contacts, documents: @documents, schedules: @schedules, hsCodes: hsCodes, locations: locations, cargoItemTypes: cargo_item_types}
    response_handler(resp)
  end

  def edit_price
    shipment = Shipment.find(params[:id])
    shipment.total_price = {value: params[:priceObj]["value"], currency: params[:priceObj]["currency"]}
    shipment.save!
    message = {
        title: 'Shipment Price Change',
        message: "Your shipment #{shipment.imc_reference} has an updated price. Your new total is #{params[:priceObj]["currency"]} #{params[:priceObj]["value"]}. For any issues, please contact your support agent.",
        shipmentRef: shipment.imc_reference
      }
      add_message_to_convo(shipment.shipper, message, true)
    response_handler(shipment)
  end

  def edit_time
    shipment = Shipment.find(params[:id])
    new_etd = DateTime.parse(params[:timeObj]["newEtd"])
    new_eta = DateTime.parse(params[:timeObj]["newEta"])
    shipment.planned_eta = new_eta
    shipment.planned_etd = new_etd
    shipment.schedule_set[0]["eta"] = new_eta
    shipment.schedule_set[0]["etd"] = new_etd
    shipment.save!
    message = {
        title: 'Shipment Schedule Updated',
        message: "Your shipment #{shipment.imc_reference} has an updated schedule. Your new estimated departure is #{params[:timeObj]["newEtd"]}, estimated to arrive at #{params[:timeObj]["newEta"]}. For any issues, please contact your support agent.",
        shipmentRef: shipment.imc_reference
      }
      add_message_to_convo(shipment.shipper, message, true)
    response_handler(shipment)
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
        shipper_confirmation_email(@shipment.shipper, @shipment)
        message = {
          title: 'Booking Accepted',
          message: "Your booking has been accepted! If you have any further questions or edis to your booking please contact the support department.",
          shipmentRef: @shipment.imc_reference
        }
        add_message_to_convo(@shipment.shipper, message, true)
        response_handler(@shipment)
      when "decline"
        @shipment.decline!
        message = {
          title: 'Booking Declined',
          message: "Your booking has been declined! This could be due to a number of reasons including cargo size/weight and gods type. For more info contact us through the support channels.",
          shipmentRef: @shipment.imc_reference
        }
        add_message_to_convo(@shipment.shipper, message, true)
        response_handler(@shipment)
      when "ignore"
        @shipment.ignore!
        response_handler({})
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
  
  end

  def document_action
    @document = Document.find(params[:id])
    @user = @document.user
    type = params[:type]
    text = params[:text]
    case type
    when 'approve'
      @document.approved = 'approved'
      @document.save!
      message = {
        title: 'Document Approved',
        message: "Your document #{@document.text} was approved",
        shipmentRef: @document.shipment.imc_reference
      }
      add_message_to_convo(@user, message, true)
    when 'reject'
      @document.approved = 'rejected'
      @document.save!
      message = {
        title: 'Document Rejected',
        message: "Your document #{@document.text} was rejected: #{text}",
        shipmentRef: @document.shipment.imc_reference
      }
      add_message_to_convo(@user, message, true)
    end

    tmp = @document.as_json
    tmp["signed_url"] =  @document.get_signed_url
    response_handler(tmp)

    
  end

  private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name.include?("admin") && current_user.tenant_id === Tenant.find_by_subdomain(params[:subdomain_id]).id
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end

  def shipment_params
    params.require(:shipment).permit(:total_price, :planned_pickup_date,:origin_id, :destination_id)
  end
end
