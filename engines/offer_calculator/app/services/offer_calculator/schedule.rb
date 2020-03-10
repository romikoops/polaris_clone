# frozen_string_literal: true

module OfferCalculator
  class Schedule # rubocop:disable Metrics/ClassLength
    include ActiveModel::Model

    attr_accessor :id, :origin_hub_id, :destination_hub_id,
                  :origin_hub_name, :destination_hub_name, :mode_of_transport,
                  :total_price, :eta, :etd, :closing_date, :vehicle_name, :trip_id,
                  :quote, :carrier_name, :load_type, :voyage_code, :vessel

    def origin_hub
      Legacy::Hub.find origin_hub_id
    end

    def destination_hub
      Legacy::Hub.find destination_hub_id
    end

    def hub_for_carriage(carriage)
      return origin_hub      if carriage == 'pre'
      return destination_hub if carriage == 'on'

      raise ArgumentError, "carriage must be 'pre' or 'on'"
    end

    def trip
      Legacy::Trip.find trip_id
    end

    def self.quote_trip_end_date
      31.days.from_now.beginning_of_day
    end

    def self.quote_trip_start_date
      5.days.from_now.beginning_of_day
    end

    def self.quote_trip_closing_date
      2.days.from_now.beginning_of_day
    end

    def to_detailed_hash
      keys = %i(id mode_of_transport total_price eta etd closing_date vehicle_name
                carrier_name voyage_code vessel trip_id)

      as_json.symbolize_keys.slice(*keys).merge(origin_hub: detailed_hash_hub_data_for(:origin),
                                                destination_hub: detailed_hash_hub_data_for(:destination))
    end

    def self.from_routes(routes, current_etd_in_search, delay_in_days, load_type) # rubocop:disable Metrics/MethodLength
      grouped_data_from_routes = OfferCalculator::Route.group_data_by_attribute(routes)

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
          carriers.name                 AS carrier_name,
          trips.id                      AS trip_id,
          trips.vessel                  AS vessel,
          trips.voyage_code             AS voyage_code
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
        LEFT OUTER JOIN carriers AS carriers ON tenant_vehicles.carrier_id = carriers.id
        WHERE itineraries.id       IN (:itinerary_ids)
        AND   origin_stops.id      IN (:origin_stop_ids)
        AND   destination_stops.id IN (:destination_stop_ids)
        AND   tenant_vehicles.id IN (:tenant_vehicle_ids)
        AND   origin_layovers.trip_id = destination_layovers.trip_id
        AND   origin_layovers.etd < :end_date
        AND   origin_layovers.etd > :start_date
        AND   trips.load_type = :load_type
        ORDER BY origin_layovers.etd
      "

      sanitized_query = ActiveRecord::Base.sanitize_sql_array(
        [
          raw_query,
          {
            itinerary_ids: grouped_data_from_routes[:itinerary_ids],
            origin_stop_ids: grouped_data_from_routes[:origin_stop_ids],
            destination_stop_ids: grouped_data_from_routes[:destination_stop_ids],
            tenant_vehicle_ids: grouped_data_from_routes[:tenant_vehicle_ids],
            carrier_ids: grouped_data_from_routes[:carrier_ids],
            end_date: current_etd_in_search + delay_in_days.days,
            start_date: current_etd_in_search,
            load_type: load_type
          }
        ]
      )

      ActiveRecord::Base.connection.exec_query(sanitized_query).map do |attributes|
        OfferCalculator::Schedule.new(attributes.merge(id: SecureRandom.uuid))
      end
    end

    def self.from_trip(trip) # rubocop:disable Metrics/AbcSize
      new(
        id: SecureRandom.uuid,
        mode_of_transport: trip.itinerary.mode_of_transport,
        eta: trip.end_date,
        etd: trip.start_date,
        closing_date: trip.closing_date,
        origin_hub_id: trip.itinerary.first_stop.hub.id,
        destination_hub_id: trip.itinerary.last_stop.hub.id,
        origin_hub_name: trip.itinerary.first_stop.hub.name,
        destination_hub_name: trip.itinerary.last_stop.hub.name,
        vehicle_name: trip.tenant_vehicle.name,
        carrier_name: trip.tenant_vehicle&.carrier&.name,
        trip_id: trip.id,
        load_type: trip.load_type
      )
    end

    def self.from_trips(trips)
      trips.map do |trip|
        from_trip(trip).to_detailed_hash
      end
    end

    private

    def detailed_hash_hub_data_for(target)
      %i(id name).each_with_object({}) do |hub_attribute, obj|
        obj[hub_attribute] = send("#{target}_hub_#{hub_attribute}")
      end
    end
  end
end
