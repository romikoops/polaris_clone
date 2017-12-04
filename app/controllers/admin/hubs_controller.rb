class Admin::HubsController < ApplicationController
  include ExcelTools
  include Response
  before_action :require_login_and_role_is_admin

  

  def index
    @ocean_hubs = Hub.prepped_ports
    json_response(@ocean_hubs, 200)
  end

  def set_status
    hub = Hub.find(params[:hub_id])
    hub.toggle_hub_status!

    render json: { updated_hub_status: hub.hub_status }, status: 200
  end

  def overwrite
    if params[:file]
      req = {'xlsx' => params[:file]}
      overwrite_hubs(req)
      json_response(true, 200)
    else
      json_response(false, 200)
    end
    
  end

  private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name == "admin"
      # flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end
