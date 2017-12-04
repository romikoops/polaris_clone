class Admin::ShipmentsController < ApplicationController
  before_action :require_login_and_role_is_admin

  

  def index
    @documents = {}
    @requested_shipments = Shipment.where(status: "requested")
    @documents['requested_shipments'] = Document.get_documents_for_array(@requested_shipments)
    @open_shipments = Shipment.where(status: ["accepted", "in_progress"])
    @documents['open_shipments'] = Document.get_documents_for_array(@open_shipments)
    @finished_shipments = Shipment.where(status: ["declined", "finished"])
    @documents['finished_shipments'] = Document.get_documents_for_array(@finished_shipments)
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
        redirect_to admin_shipments_path
      when "decline"
        @shipment.decline!
        redirect_to admin_shipments_path
      else
        raise "Unknown action!"
      end
    else # This happens when shipment is edited with edit form
      if @shipment.update(shipment_params)
        redirect_to admin_shipments_path
      else
        render 'edit'
      end
    end
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
