class Admin::HubsController < ApplicationController
  include ExcelTools
  include Response
  before_action :require_login_and_role_is_admin

  

  def index
    @hubs = Hub.prepped(current_user)
    
    response_handler(@hubs)
  end
  def show
    @hub = Hub.find(params[:id])
    @related_hubs = @hub.nexus.hubs
    @service_charges = @hub.service_charge
    # @schedules = @hub.schedules.limit(10)
    @hub_routes = HubRoute.where('endhub_id = ? OR starthub_id = ?', @hub.id, @hub.id)
    
    @routes = []
    @schedules = []
    @hub_routes.each do |hr|
      @routes.push(Route.find(hr.route_id))
      @schedules += hr.schedules.limit(5).to_a
    end
    
    resp = {hub: @hub, routes: @routes, relatedHubs: @related_hubs, serviceCharges: @service_charges, schedules: @schedules, hubRoutes: @hub_routes}
    response_handler(resp)
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
      response_handler(true)
    else
      response_handler(false)
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
