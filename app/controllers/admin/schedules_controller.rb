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
    itinerary = Itinerary.find_by(id: params[:id], sandbox: @sandbox)
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
    # TODO: Method should be called `upload`

    Document.create!(
      text: '',
      doc_type: 'schedules',
      sandbox: @sandbox,
      tenant: current_tenant,
      file: upload_params[:file]
    )

    file = upload_params[:file].tempfile
    options = { tenant: current_tenant,
                file_or_path: file,
                options: {
                  user: current_user,
                  sandbox: @sandbox
                } }
    uploader = ExcelDataServices::Loaders::Uploader.new(options)

    insertion_stats_or_errors = uploader.perform
    response_handler(insertion_stats_or_errors)
  end

  def destroy
    Trip.find_by(id: params[:id], sandbox: @sandbox).destroy
    response_handler(true)
  end

  def layovers
    response_handler(trip_layovers)
  end

  def schedules_by_itinerary
    if params[:file]
      itinerary = Itinerary.find_by(id: params[:id], sandbox: @sandbox)

      req = { 'xlsx' => params[:file], 'itinerary' => itinerary }
      results = ExcelTool::OverwriteSchedulesByItinerary.new(
        params: req,
        user: current_user,
        sandbox: @sandbox
      ).perform
      response_handler(results)
    else
      response_handler(false)
    end
  end

  def overwrite_trains
    if params[:file]
      req = { 'xlsx' => params[:file] }
      results = ExcelTool::ScheduleOverwriter.new(
        params: req,
        mot: 'rail',
        user: current_user,
        sandbox: @sandbox
      ).perform
      response_handler(results)
    else
      response_handler(false)
   end
  end

  def overwrite_vessels
    if params[:file]
      req = { 'xlsx' => params[:file] }
      results = ExcelTool::ScheduleOverwriter.new(
        params: req,
        mot: 'ocean',
        user: current_user,
        sandbox: @sandbox
      ).perform
      response_handler(results)
    else
      response_handler(false)
   end
  end

  def overwrite_air
    if params[:file]
      req = { 'xlsx' => params[:file] }
      results = ExcelTool::ScheduleOverwriter.new(
        params: req,
        mot: 'air',
        user: current_user,
        sandbox: @sandbox
      ).perform
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
    tenant.itineraries.where(mode_of_transport: mot, sandbox: @sandbox).flat_map do |itin|
      itin.trips.limit(10).order(:start_date)
    end
  end

  def tenant
    @tenant ||= Tenant.find_by(id: current_user.tenant_id)
  end

  def itinerary_route_json
    Itinerary.where(tenant_id: current_user.tenant_id, sandbox: @sandbox).map(&:as_options_json)
  end

  def stops
    @stops ||= itinerary.stops.order(:index)
  end

  def vehicle
    @vehicle ||= TenantVehicle.find_by(id: params[:vehicleTypeId], sandbox: @sandbox).id
  end

  def itin_weekly_schedules
    itinerary.generate_weekly_schedules(
      stops_in_order: stops,
      steps_in_order: params[:steps],
      start_date: params[:startDate],
      end_date: params[:endDate],
      ordinal_array: params[:weekdays],
      tenant_vehicle_id: vehicle,
      closing_date_buffer: params[:closing_date].to_i,
      load_type: params[:load_type].to_i,
      sandbox: @sandbox
    )
  end

  def itinerary
    @itinerary ||= Itinerary.find_by(id: params[:itinerary], sandbox: @sandbox)
  end

  def itineraries
    @itineraries ||= Itinerary.where(tenant_id: current_user.tenant_id, sandbox: @sandbox)
  end

  def trip_layovers
    trip.layovers.order(:stop_index).map do |layover|
      { layover: layover, stop: layover.stop, hub: layover.stop.hub }
    end
  end

  def trip
    @trip ||= Trip.find_by(id: params[:id], sandbox: @sandbox)
  end

  def upload_params
    params.permit(:file)
  end
end
