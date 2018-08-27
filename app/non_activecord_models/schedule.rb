# frozen_string_literal: true

class Schedule
  include ActiveModel::Model

  attr_accessor :id, :origin_hub_id, :destination_hub_id,
    :origin_hub_name, :destination_hub_name, :mode_of_transport,
    :total_price, :eta, :etd, :closing_date, :vehicle_name, :trip_id

  def origin_hub
    Hub.find origin_hub_id
  end

  def destination_hub
    Hub.find destination_hub_id
  end

  def hub_for_carriage(carriage)
    return origin_hub      if carriage == "pre"
    return destination_hub if carriage == "on"

    raise ArgumentError, "carriage must be 'pre' or 'on'"
  end

  def trip
    Trip.find trip_id
  end

  def to_detailed_hash
    {
      id:                id,
      origin_hub:        detailed_hash_hub_data_for(:origin),
      destination_hub:   detailed_hash_hub_data_for(:destination),
      mode_of_transport: mode_of_transport,
      total_price:       total_price,
      eta:               eta,
      etd:               etd,
      closing_date:      closing_date,
      vehicle_name:      vehicle_name,
      trip_id:           trip_id
    }
  end

  def self.from_routes(routes, current_etd_in_search, delay_in_days)
    grouped_data_from_routes = Route.group_data_by_attribute(routes)
    
    raw_query = "
      SELECT DISTINCT
        origin_hubs.id                AS origin_hub_id,
        destination_hubs.id           AS destination_hub_id,
        origin_hubs.name              AS origin_hub_name,
        destination_hubs.name         AS destination_hub_name,
        itineraries.mode_of_transport AS mode_of_transport,
        destination_layovers.eta      AS eta,
        origin_layovers.etd           AS etd,
        origin_layovers.closing_date  AS closing_date,
        tenant_vehicles.name          AS vehicle_name,
        trips.id                      AS trip_id
      FROM itineraries
      JOIN stops    AS origin_stops         ON itineraries.id       = origin_stops.itinerary_id
      JOIN stops    AS destination_stops    ON itineraries.id       = destination_stops.itinerary_id
      JOIN layovers AS origin_layovers      ON origin_stops.id      = origin_layovers.stop_id
      JOIN layovers AS destination_layovers ON destination_stops.id = destination_layovers.stop_id
      JOIN trips    AS trips                ON trips.id             = origin_layovers.trip_id
      JOIN hubs     AS origin_hubs          ON origin_hubs.id       = origin_stops.hub_id
      JOIN hubs     AS destination_hubs     ON destination_hubs.id  = destination_stops.hub_id
      JOIN tenant_vehicles AS tenant_vehicles
        ON trips.tenant_vehicle_id = tenant_vehicles.id
      WHERE itineraries.id       IN (?)
      AND   origin_stops.id      IN (?)
      AND   destination_stops.id IN (?)
      AND   origin_layovers.trip_id = destination_layovers.trip_id
      AND   origin_layovers.closing_date < ?
      AND   origin_layovers.closing_date > ?
      ORDER BY origin_layovers.etd
    "
    sanitized_query = ApplicationRecord.public_sanitize_sql(
      [
        raw_query,
        grouped_data_from_routes[:itinerary_ids],
        grouped_data_from_routes[:origin_stop_ids],
        grouped_data_from_routes[:destination_stop_ids],
        current_etd_in_search + delay_in_days.days,
        current_etd_in_search
      ]
    )
      
    ActiveRecord::Base.connection.exec_query(sanitized_query).map do |attributes|
      Schedule.new(attributes.merge(id: SecureRandom.uuid))
    end
  end

  private

  def detailed_hash_hub_data_for(target)
    %i(id name).each_with_object({}) do |hub_attribute, obj|
      obj[hub_attribute] = send("#{target}_hub_#{hub_attribute}")
    end
  end
end
