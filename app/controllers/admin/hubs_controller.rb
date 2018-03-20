class Admin::HubsController < ApplicationController
  include ExcelTools
  include ItineraryTools
  include Response
  before_action :require_login_and_role_is_admin

  

  def index
    @hubs = Hub.prepped(current_user)
    
    response_handler(@hubs)
  end
  def create
    new_loc = Location.create_and_geocode(params[:location].as_json)
    new_nexus = Location.from_short_name("#{params[:location][:city]}, #{params[:location][:country]}", 'nexus')
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
    location = hub.location
    layovers = hub.layovers.limit(20)
    routes = get_itineraries_for_hub(hub)
    customs = get_items_query("customsFees", [{"tenant_id" => current_user.tenant_id}, {"nexus_id" => hub.nexus_id}])
    charges = get_items_query("localCharges", [{"tenant_id" => current_user.tenant_id}, {"nexus_id" => hub.nexus_id}])
    resp = {hub: hub, routes: routes, relatedHubs: related_hubs, schedules: layovers, charges: charges, customs: customs, location: hub.location}
    response_handler(resp)
  end
  def set_status
    hub = Hub.find(params[:hub_id])
    hub.toggle_hub_status!
    response_handler(hub)
  end
  def delete
    hub = Hub.find(params[:hub_id])
    hub.destroy!
    response_handler({id: params[:hub_id]})
  end
  def update
    hub = Hub.find(params[:id])
    location = hub.location
    new_loc = params[:location].as_json
    new_hub = params[:data].as_json
    hub.update_attributes(new_hub)
    location.update_attributes(new_loc)
    response_handler({hub: hub, location: location})
  end
  def overwrite
    if params[:file]
      req = {'xlsx' => params[:file]}
      resp = overwrite_hubs(req)
      # resp = []
      # hubs.each do |po|
      #   resp << {data: po, location: po.location}
      # end
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
