# frozen_string_literal: true

class Admin::SchedulesController < Admin::AdminBaseController
  before_action :initialize_variables, only: %i(index auto_generate_schedules)

  def index
    map_data = MapDatum.where(organization: current_organization)
    response_handler(
      mapData: map_data,
      itineraries: itinerary_route_json
    )
  end

  def show
    itinerary = Itinerary.find_by(id: params[:id])
    schedules = trips_for_table(itinerary: itinerary, limit: 100)
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
    options[:organization_id] = current_organization.id
    url = DocumentService::ScheduleSheetWriter.new(options).perform
    response_handler(url: url, key: 'schedules')
  end

  def generate_schedules_from_sheet
    handle_upload(
      params: upload_params,
      text: "#{current_organization.slug}:schedule_generator",
      type: 'schedules_generator',
      options: {
        user: organization_user
      }
    )
  end

  def upload
    handle_upload(
      params: upload_params,
      text: "#{current_organization.slug}:schedules",
      type: 'schedules',
      options: {
        user: organization_user
      }
    )
  end

  def destroy
    Trip.find_by(id: params[:id]).destroy
    response_handler(true)
  end

  def layovers
    response_handler(trip_layovers)
  end


  private

  def initialize_variables
    @train_schedules = mot_schedule('rail')
    @ocean_schedules = mot_schedule('ocean')
    @air_schedules = mot_schedule('air')
    @truck_schedules = mot_schedule('truck')
  end

  def mot_schedule(mot)
    Itinerary.where(organization: current_organization, mode_of_transport: mot).flat_map do |itin|
      itin.trips.limit(10).order(:start_date)
    end
  end

  def itinerary_route_json
    Itinerary.where(organization_id: current_organization.id).map(&:as_options_json)
  end

  def stops
    @stops ||= itinerary.stops.order(:index)
  end

  def vehicle
    @vehicle ||= TenantVehicle.find_by(id: params[:vehicleTypeId]).id
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
      load_type: params[:load_type].to_i
    )
  end

  def itinerary
    @itinerary ||= Itinerary.find_by(id: params[:itinerary])
  end

  def itineraries
    @itineraries ||= Itinerary.where(organization_id: current_organization.id)
  end

  def trip_layovers
    trip.layovers.order(:stop_index).map do |layover|
      { layover: layover, stop: layover.stop, hub: layover.stop.hub }
    end
  end

  def trips_for_table(itinerary:, limit:)
    itinerary
      .trips
      .lastday_today
      .left_joins(tenant_vehicle: :carrier)
      .select('trips.*, tenant_vehicles.name AS service_level, carriers.name AS carrier')
      .order(:start_date)
      .limit(limit)
      .map(&:attributes)
  end

  def trip
    @trip ||= Trip.find_by(id: params[:id])
  end

  def upload_params
    params.permit(:file)
  end
end
