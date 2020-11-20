# frozen_string_literal: true

module OfferCalculator
  module Queries
    class FullAttributesFromItineraryIds
      def initialize(args = {})
        @itinerary_ids = args[:itinerary_ids] || args["itinerary_ids"]
        @options = args[:options] || args["options"]
      end

      def perform
        sanitized_query = ActiveRecord::Base.sanitize_sql_array([raw_query, binds])
        ActiveRecord::Base.connection.exec_query(sanitized_query).to_a
      end

      private

      attr_reader :options, :itinerary_ids

      def binds
        {itinerary_ids: itinerary_ids, load_type: options[:load_type]}
      end

      def raw_query
        <<-SQL
          SELECT
            MAX(itineraries.id)                AS itinerary_id,
            MAX(itineraries.name)              AS itinerary_name,
            MAX(itineraries.transshipment)     AS itinerary_transshipment,
            MAX(itineraries.mode_of_transport) AS mode_of_transport,
            MAX(origin_stops.id)               AS origin_stop_id,
            MAX(destination_stops.id)          AS destination_stop_id,
            MAX(origin_hubs.id)                AS origin_hub_id,
            MAX(destination_hubs.id)           AS destination_hub_id,
            MAX(origin_hubs.name)              AS origin_hub_name,
            MAX(destination_hubs.name)         AS destination_hub_name,
            MAX(origin_nexuses.id)             AS origin_nexus_id,
            MAX(destination_nexuses.id)        AS destination_nexus_id,
            MAX(origin_nexuses.name)           AS origin_nexus_name,
            MAX(destination_nexuses.name)      AS destination_nexus_name,
            MAX(origin_nexuses.locode)         AS origin_locode,
            MAX(destination_nexuses.locode)    AS destination_locode,
            MAX(origin_nexuses.latitude)       AS origin_latitude,
            MAX(origin_nexuses.longitude)      AS origin_longitude,
            MAX(destination_nexuses.latitude)  AS destination_latitude,
            MAX(destination_nexuses.longitude) AS destination_longitude,
            MAX(origin_countries.code)         AS origin_country,
            MAX(destination_countries.code)    AS destination_country,
            MAX(tenant_vehicles.id)             AS tenant_vehicle_id,
            STRING_AGG(pricings_pricings.cargo_class, ',') AS cargo_classes,
            STRING_AGG(
              DISTINCT CASE
                WHEN origin_trucking_type_availabilities.load_type = :load_type
                  AND  origin_trucking_type_availabilities.carriage = 'pre'
                  THEN origin_trucking_type_availabilities.truck_type
              END,
              ','
            ) AS origin_truck_types,
            STRING_AGG(
              DISTINCT CASE
                WHEN destination_trucking_type_availabilities.load_type = :load_type
                  AND  destination_trucking_type_availabilities.carriage = 'on'
                  THEN destination_trucking_type_availabilities.truck_type
              END,
              ','
            ) AS destination_truck_types
          FROM itineraries
          JOIN pricings_pricings
            ON itineraries.id = pricings_pricings.itinerary_id
          JOIN stops AS origin_stops
            ON itineraries.id = origin_stops.itinerary_id
          JOIN stops AS destination_stops
            ON itineraries.id = destination_stops.itinerary_id
          JOIN hubs AS origin_hubs
            ON origin_hubs.id = origin_stops.hub_id
          JOIN hubs AS destination_hubs
            ON destination_hubs.id = destination_stops.hub_id
          JOIN addresses AS origin_hubs_addresses
            ON origin_hubs.address_id = origin_hubs_addresses.id
          JOIN addresses AS destination_hubs_addresses
            ON destination_hubs.address_id = destination_hubs_addresses.id
          JOIN countries AS origin_countries
            ON origin_hubs_addresses.country_id = origin_countries.id
          JOIN countries AS destination_countries
            ON destination_hubs_addresses.country_id = destination_countries.id
          JOIN tenant_vehicles AS tenant_vehicles
            ON tenant_vehicles.id = pricings_pricings.tenant_vehicle_id
          JOIN nexuses AS origin_nexuses
            ON origin_nexuses.id = origin_hubs.nexus_id
          JOIN nexuses AS destination_nexuses
            ON destination_nexuses.id = destination_hubs.nexus_id
          LEFT OUTER JOIN trucking_hub_availabilities AS origin_trucking_hub_availabilities
            ON origin_hubs.id = origin_trucking_hub_availabilities.hub_id
          LEFT OUTER JOIN trucking_hub_availabilities AS destination_trucking_hub_availabilities
            ON destination_hubs.id = destination_trucking_hub_availabilities.hub_id
          LEFT OUTER JOIN trucking_type_availabilities AS origin_trucking_type_availabilities
            ON origin_trucking_hub_availabilities.type_availability_id =
               origin_trucking_type_availabilities.id
          LEFT OUTER JOIN trucking_type_availabilities AS destination_trucking_type_availabilities
            ON destination_trucking_hub_availabilities.type_availability_id =
               destination_trucking_type_availabilities.id
          WHERE itineraries.id IN (:itinerary_ids)
          AND   origin_stops.index < destination_stops.index
          AND   pricings_pricings.load_type = :load_type
          GROUP BY origin_stops.id, destination_stops.id
        SQL
      end
    end
  end
end
