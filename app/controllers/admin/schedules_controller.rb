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
  def show
    itinerary = Itinerary.find(params[:id])
    schedules = itinerary.trips.limit(20).order(:start_date)

    response_handler({schedules: schedules, itinerary: itinerary})
  end
  def auto_generate_schedules
    tenant = Tenant.find(current_user.tenant_id)
    mot = params[:mot]
    itinerary = Itinerary.find(params[:itinerary])
    stops = itinerary.stops.order(:index)
    closing_date_buffer = params[:closing_date].to_i
    vehicle = TenantVehicle.find(params[:vehicleTypeId]).vehicle_id
    resp = itinerary.generate_weekly_schedules(stops, params[:steps], params[:startDate], params[:endDate], params[:weekdays], vehicle, closing_date_buffer)
    train_schedules = tenant.itineraries.where(mode_of_transport: 'train').flat_map{ |it| it.trips.limit(10).order(:start_date)}
    ocean_schedules = tenant.itineraries.where(mode_of_transport: 'ocean').flat_map{ |it| it.trips.limit(10).order(:start_date)}
    air_schedules = tenant.itineraries.where(mode_of_transport: 'air').flat_map{ |it| it.trips.limit(10).order(:start_date)}
    itineraries = Itinerary.where(tenant_id: current_user.tenant_id)
    # 
    response_handler({air: air_schedules, train: train_schedules, ocean: ocean_schedules, itineraries: itineraries, stats: resp})
  end
  def destroy
    Trip.find(params[:id]).destroy
    response_handler(true)
  end
  def layovers
    trip = Trip.find(params[:id])
    layovers = trip.layovers.order(:stop_index).map { |l| {layover: l, stop: l.stop, hub: l.stop.hub}  }
    response_handler(layovers)
  end
  def schedules_by_itinerary
    if params[:file]
      itinerary = Itinerary.find(params[:id])
      req = {'xlsx' => params[:file], 'itinerary' => itinerary}
      results = overwrite_schedules_by_itinerary(req, current_user)
      response_handler(results)
    else
      response_handler(false)
    end
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
