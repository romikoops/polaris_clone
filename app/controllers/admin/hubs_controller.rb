class Admin::HubsController < ApplicationController
  include ExcelTools
  include Response
  before_action :require_login_and_role_is_admin

  

  def index
    @hubs = Hub.prepped(current_user)
    
    response_handler(@hubs)
  end
  def create
    new_loc = Location.create_and_geocode(params[:location].as_json)
    new_nexus = Location.from_short_name("#{params[:location][:city]}, #{params[:location][:country]}")
    hub = params[:hub].as_json
    hub["tenant_id"] = current_user.tenant_id
    hub["location_id"] = new_loc.id
    hub["nexus_id"] = new_nexus.id
    new_hub = Hub.create!(hub)
    response_handler({data: new_hub, location: new_loc})
  end
  def show
    hub = Hub.find(params[:id])
    related_hubs = hub.nexus.hubs
    # schedules = hub.schedules.limit(10)
    hub_routes = HubRoute.where('endhub_id = ? OR starthub_id = ?', hub.id, hub.id)
    
    routes = []
    schedules = []
    hub_routes.each do |hr|
      routes.push(Route.find(hr.route_id))
      schedules += hr.schedules.limit(5).to_a
    end
    detailed_routes = routes.map do |route| 
      route.detailed_hash(
        nexus_names: true
      )
    end
    
    resp = {hub: hub, routes: detailed_routes, relatedHubs: related_hubs, schedules: schedules, hubRoutes: hub_routes}
    response_handler(resp)
  end
  def set_status
    hub = Hub.find(params[:hub_id])
    hub.toggle_hub_status!
    response_handler(hub)
  end

  def overwrite
    if params[:file]
      req = {'xlsx' => params[:file]}
      hubs = overwrite_hubs(req)
      resp = []
      hubs.each do |po|
        resp << {data: po, location: po.location}
      end
      response_handler(resp)
    else
      response_handler(false)
    end
    
  end

  private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name.include?("admin") && current_user.tenant_id === Tenant.find_by_subdomain(params[:subdomain_id]).id
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end
