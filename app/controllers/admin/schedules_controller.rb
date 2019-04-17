# frozen_string_literal: true

class Admin::SchedulesController < Admin::AdminBaseController
  before_action :initialize_variables, only: %i(index auto_generate_schedules)
  include ItineraryTools

  def index
    map_data = current_user.tenant.map_data
    response_handler(
      mapData: map_data,
      itineraries: itinerary_route_json
    )
  end

  def show
    itinerary = Itinerary.find(params[:id])
    schedules = itinerary.trips.lastday_today.limit(100).order(:start_date)
    response_handler(schedules: schedules, itinerary: itinerary.as_options_json)
  end

  def auto_generate_schedules
    response_handler(air: @air_schedules,
                     train: @train_schedules,
                     ocean: @ocean_schedules,
                     itineraries: itineraries,
                     stats: itin_weekly_schedules)
  end

  def download_schedules
    options = params[:options].as_json.symbolize_keys
    options[:tenant_id] = current_user.tenant_id
    url = DocumentService::ScheduleSheetWriter.new(options).perform
    response_handler(url: url, key: 'schedules')
  end

  def generate_schedules_from_sheet
    file = upload_params[:file].tempfile

    options = { tenant: current_tenant,
                file_or_path: file }
    uploader = ExcelDataServices::Loaders::Uploader.new(options)

    insertion_stats_or_errors = uploader.perform
    response_handler(insertion_stats_or_errors)
  end

  def destroy
    Trip.find(params[:id]).destroy
    response_handler(true)
  end

  def layovers
    response_handler(trip_layovers)
  end

  def schedules_by_itinerary
    if params[:file]
      itinerary = Itinerary.find(params[:id])

      req = { 'xlsx' => params[:file], 'itinerary' => itinerary }
      results = ExcelTool::OverwriteSchedulesByItinerary.new(params: req, _user: current_user).perform
      response_handler(results)
    else
      response_handler(false)
    end
  end

  def overwrite_trains
    if params[:file]
      req = { 'xlsx' => params[:file] }
      results = ExcelTool::ScheduleOverwriter.new(params: req, mot: 'rail', _user: current_user).perform
      response_handler(results)
    else
      response_handler(false)
   end
  end

  def overwrite_vessels
    if params[:file]
      req = { 'xlsx' => params[:file] }
      results = ExcelTool::ScheduleOverwriter.new(params: req, mot: 'ocean', _user: current_user).perform
      response_handler(results)
    else
      response_handler(false)
   end
  end

  def overwrite_air
    if params[:file]
      req = { 'xlsx' => params[:file] }
      results = ExcelTool::ScheduleOverwriter.new(params: req, mot: 'air', _user: current_user).perform
      response_handler(results)
    else
      response_handler(false)
   end
  end

  private

  def initialize_variables
    @train_schedules = mot_schedule('rail')
    @ocean_schedules = mot_schedule('ocean')
    @air_schedules = mot_schedule('air')
    @truck_schedules = mot_schedule('truck')
  end

  def mot_schedule(mot)
    tenant.itineraries.where(mode_of_transport: mot).flat_map do |itin|
      itin.trips.limit(10).order(:start_date)
    end
  end

  def tenant
    @tenant ||= Tenant.find(current_user.tenant_id)
  end

  def itinerary_route_json
    Itinerary.where(tenant_id: current_user.tenant_id).map(&:as_options_json)
  end

  def stops
    @stops ||= itinerary.stops.order(:index)
  end

  def vehicle
    @vehicle ||= TenantVehicle.find(params[:vehicleTypeId]).id
  end

  def itin_weekly_schedules
    itinerary.generate_weekly_schedules(stops, params[:steps], params[:startDate],
                                        params[:endDate], params[:weekdays], vehicle, params[:closing_date].to_i)
  end

  def itinerary
    @itinerary ||= Itinerary.find(params[:itinerary])
  end

  def itineraries
    @itineraries ||= Itinerary.where(tenant_id: current_user.tenant_id)
  end

  def trip_layovers
    trip.layovers.order(:stop_index).map do |layover|
      { layover: layover, stop: layover.stop, hub: layover.stop.hub }
    end
  end

  def trip
    @trip ||= Trip.find(params[:id])
  end

  def upload_params
    params.permit(:file)
  end
end
