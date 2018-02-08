class Admin::DashboardController < ApplicationController
  include ItineraryTools
  before_action :require_login_and_role_is_admin
  def index
    @requested_shipments = Shipment.where(status: "requested", tenant_id: current_user.tenant_id)
    @open_shipments = Shipment.where(status: ["accepted", "in_progress", "confirmed"], tenant_id: current_user.tenant_id)
    @finished_shipments = Shipment.where(status: ["declined", "finished"], tenant_id: current_user.tenant_id)
    itineraries = Itinerary.where(tenant_id: current_user.tenant_id)
    @detailed_itineraries = get_itineraries(current_user.tenant_id)
    @hubs = Hub.prepped(current_user)
    tenant = Tenant.find(current_user.tenant_id)
    @train_schedules = tenant.schedules.where(mode_of_transport: 'train').paginate(:page => params[:page], :per_page => 5)
    @ocean_schedules = tenant.schedules.where(mode_of_transport: 'ocean').paginate(:page => params[:page], :per_page => 5)
    @air_schedules = tenant.schedules.where(mode_of_transport: 'air').paginate(:page => params[:page], :per_page => 5)
    # 
    response_handler({air: @air_schedules, train: @train_schedules, ocean: @ocean_schedules, itineraries: @detailed_itineraries, hubs: @hubs, shipments: {requested: @requested_shipments, open: @open_shipments, finished: @finished_shipments}})
  end

  private

  def require_login_and_role_is_admin
    unless user_signed_in? && current_user.role.name.include?("admin") && current_user.tenant_id === Tenant.find_by_subdomain(params[:subdomain_id]).id
      flash[:error] = "You are not authorized to access this section."
      redirect_to root_path
    end
  end
end
