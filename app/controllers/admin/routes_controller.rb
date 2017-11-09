class Admin::RoutesController < ApplicationController
  before_action :require_login_and_role_is_admin

  layout 'dashboard'

  def index
    @routes = Route.where(tenant_id: current_user.tenant_id)
    @number_of_columns = @routes.map { |r| r.stops.length }.max || 1
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