class Admin::SchedulesController < ApplicationController
  before_action :require_login_and_role_is_admin
  include ItineraryTools
  include ExcelTools

  

  def index
    tenant = Tenant.find(current_user.tenant_id)
    train_schedules = tenant.itineraries.where(mode_of_transport: 'train').flat_map{ |it| it.trips.limit(10).order(:start_date)}
    ocean_schedules = tenant.itineraries.where(mode_of_transport: 'ocean').flat_map{ |it| it.trips.limit(10).order(:start_date)}
    air_schedules = tenant.itineraries.where(mode_of_transport: 'air').flat_map{ |it| it.trips.limit(10).order(:start_date)}
    itineraries = Itinerary.where(tenant_id: current_user.tenant_id)
    detailed_itineraries = get_itineraries(current_user.tenant_id)
    response_handler({air: air_schedules, train: train_schedules, ocean: ocean_schedules, itineraries: itineraries, detailedItineraries: detailed_itineraries})
  end
  def auto_generate_schedules
    tenant = Tenant.find(current_user.tenant_id)
    mot = params[:mot]
    itinerary = Itinerary.find(params[:itinerary])
    stops = itinerary.stops.order(:index)
    itinerary.generate_weekly_schedules(stops, params[:steps], params[:startDate], params[:endDate], params[:weekdays], params[:vehicleTypeId])
    train_schedules = tenant.itineraries.where(mode_of_transport: 'train').flat_map{ |it| it.trips.limit(10).order(:start_date)}
    ocean_schedules = tenant.itineraries.where(mode_of_transport: 'ocean').flat_map{ |it| it.trips.limit(10).order(:start_date)}
    air_schedules = tenant.itineraries.where(mode_of_transport: 'air').flat_map{ |it| it.trips.limit(10).order(:start_date)}
    itineraries = Itinerary.where(tenant_id: current_user.tenant_id)
    # 
    response_handler({air: air_schedules, train: train_schedules, ocean: ocean_schedules, itineraries: itineraries})
  end
  def layovers
    trip = Trip.find(params[:id])
    layovers = trip.layovers.order(:stop_index).map { |l| {layover: l, stop: l.stop, hub: l.stop.hub}  }
    response_handler(layovers)
  end

  def overwrite_trains
     if params[:file]
      req = {'xlsx' => params[:file]}
       overwrite_train_schedules(req)
      response_handler(true)
    else
      response_handler(false)
    end
  end

  def overwrite_vessels
     if params[:file]
      req = {'xlsx' => params[:file]}
       overwrite_vessel_schedules(req)
      response_handler(true)
    else
      response_handler(false)
    end
  end
  def overwrite_air
     if params[:file]
      req = {'xlsx' => params[:file]}
       overwrite_air_schedules(req)
      response_handler(true)
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
