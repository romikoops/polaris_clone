class Admin::RoutesController < ApplicationController
  before_action :require_login_and_role_is_admin

  

  def index
    routes = Route.where(tenant_id: current_user.tenant_id)
    @detailed_routes = routes.map do |route| 
      route.detailed_hash(
        nexus_names: true
      )
    end
    response_handler(@detailed_routes)
  end

  def show
    @route = Route.find(params[:id]).detailed_hash(
        nexus_names: true
      )
    @hub_routes = @route.hub_routes
    @starthubs = @hub_routes.map(&:starthub).to_a
    @endhubs = @hub_routes.map(&:endhub).to_a
    # @hubs = (@starthubs + @endhubs) - (@starthubs & @endhubs)
    @schedules = @hub_routes.flat_map(&:schedules).slice!(0,20)
    @import_charges = @endhubs.map(&:service_charge)
    @export_charges = @starthubs.map(&:service_charge)
    # byebug
    resp = {startHubs: @starthubs, endHubs: @endhubs, route: @route, hubRoutes: @hub_routes, schedules: @schedules, importCharges: @import_charges, exportCharges: @export_charges}
    response_handler(resp)
  end

  def overwrite
    old_ids = Route.pluck(:id)
    new_ids = []

    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)

    route_rows = first_sheet.parse

    route_rows.each do |route_row|
      route_row = route_row.compact # remove nil's
      route = Route.find_or_create_by(name: route_row[0])
      new_ids << route.id

      route.trade_direction = route_row[1].downcase

      location_data = route_row[2..-1]
      current_hub_type = nil
      location_data.each_with_index do |el, i|
        if i % 2 == 0
          current_hub_type = el
        else
          location = Location.find_by(location_type: "hub_#{current_hub_type.downcase}", hub_name: el)
          rl = RouteLocation.find_or_create_by(route: route, location: location, position_in_hub_chain: (i+1)/2)
          route.update_attributes(starthub: rl.location) if i == 1
          route.update_attributes(endhub: rl.location) if i == location_data.length - 1
        end
      end
    end

    kicked_route_ids = old_ids - new_ids
    Route.where(id: kicked_route_ids).destroy_all

    redirect_to :back
  end

  private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name == "admin"
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end