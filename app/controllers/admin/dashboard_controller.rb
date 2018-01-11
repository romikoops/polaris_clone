class Admin::DashboardController < ApplicationController
  def index
    @requested_shipments = Shipment.where(status: "requested", tenant_id: current_user.tenant_id)
    routes = Route.where(tenant_id: current_user.tenant_id)
    @detailed_routes = routes.map do |route| 
      route.detailed_hash(
        nexus_names: true
      )
    end
    @hubs = Hub.prepped(current_user)
    tenant = Tenant.find(current_user.tenant_id)
    @train_schedules = tenant.schedules.where(mode_of_transport: 'train').paginate(:page => params[:page], :per_page => 5)
    @ocean_schedules = tenant.schedules.where(mode_of_transport: 'ocean').paginate(:page => params[:page], :per_page => 5)
    @air_schedules = tenant.schedules.where(mode_of_transport: 'air').paginate(:page => params[:page], :per_page => 5)
    # 
    response_handler({air: @air_schedules, train: @train_schedules, ocean: @ocean_schedules, routes: @detailed_routes, hubs: @hubs, shipments: @requested_shipments})
  end
end
