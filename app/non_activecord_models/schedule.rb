# frozen_string_literal: true

class Schedule
  include ActiveModel::Model

  attr_accessor :id, :origin_hub_id, :destination_hub_id, :mode_of_transport,
    :total_price, :eta, :etd, :closing_date, :trip_id

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
      origin_hub:        origin_hub.as_json(only: %i(id name)),
      destination_hub:   destination_hub.as_json(only: %i(id name)),
      mode_of_transport: mode_of_transport,
      total_price:       total_price,
      eta:               eta,
      etd:               etd,
      closing_date:      closing_date,
      trip_id:           trip_id
    }
  end

  def self.from_routes(routes, current_etd_in_search, delay_in_days)
    raw_query = "
      SELECT DISTINCT
        origin_hubs.id                AS origin_hub_id,
        destination_hubs.id           AS destination_hub_id,
        itineraries.mode_of_transport AS mode_of_transport,
        destination_layovers.eta      AS eta,
        origin_layovers.etd           AS etd,
        origin_layovers.closing_date  AS closing_date,
        trips.id                      AS trip_id
      FROM itineraries
      JOIN stops    AS origin_stops         ON itineraries.id       = origin_stops.itinerary_id
      JOIN stops    AS destination_stops    ON itineraries.id       = destination_stops.itinerary_id
      JOIN layovers AS origin_layovers      ON origin_stops.id      = origin_layovers.stop_id
      JOIN layovers AS destination_layovers ON destination_stops.id = destination_layovers.stop_id
      JOIN trips    AS trips                ON trips.id             = origin_layovers.trip_id
      JOIN hubs     AS origin_hubs          ON origin_hubs.id       = origin_stops.hub_id
      JOIN hubs     AS destination_hubs     ON destination_hubs.id  = destination_stops.hub_id
      WHERE itineraries.id       IN (?)
      AND   origin_stops.id      IN (?)
      AND   destination_stops.id IN (?)
      AND   origin_layovers.trip_id = destination_layovers.trip_id
      AND   origin_layovers.closing_date < ?
      AND   origin_layovers.closing_date > ?
      ORDER BY origin_layovers.etd
    "
    sanitized_query = ApplicationRecord.public_sanitize_sql([
      raw_query, routes.map(&:itinerary_id),
      routes.map(&:origin_stop_id), routes.map(&:destination_stop_id),
      current_etd_in_search + delay_in_days.days, current_etd_in_search
    ])

    ActiveRecord::Base.connection.exec_query(sanitized_query).map do |attributes|
      Schedule.new(attributes.merge(id: SecureRandom.uuid))
    end
  end
end
