# frozen_string_literal: true

module Queries
  module Route
    class FullAttributesFromItineraryIds
      def initialize(args={})
        @itinerary_ids = args[:itinerary_ids] || args["itinerary_ids"]
        @options       = args[:options]       || args["options"]
      end

      def perform
        sanitized_query = ApplicationRecord.public_sanitize_sql([raw_query, binds])

        ApplicationRecord.connection.exec_query(sanitized_query).to_a
      end

      private

      def binds
        truck_types_binds.merge(itinerary_ids: @itinerary_ids)
      end

      def truck_types_binds
        @options[:with_truck_types].is_a?(Hash) ? @options[:with_truck_types] : {}
      end

      def raw_query
        @options[:with_truck_types] ? raw_query_with_truck_types : raw_query_without_truck_types
      end

      def raw_query_with_truck_types
        "
          SELECT
            MAX(itineraries.id)                AS itinerary_id,
            MAX(itineraries.name)              AS itinerary_name,
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
            MAX(origin_nexuses.latitude)       AS origin_latitude,
            MAX(origin_nexuses.longitude)      AS origin_longitude,
            MAX(destination_nexuses.latitude)  AS destination_latitude,
            MAX(destination_nexuses.longitude) AS destination_longitude,
            STRING_AGG(DISTINCT origin_truck_type_availabilities.truck_type, ',')
              AS origin_truck_types,
            STRING_AGG(DISTINCT destination_truck_type_availabilities.truck_type, ',')
              AS destination_truck_types
          FROM itineraries
          JOIN stops AS origin_stops
            ON itineraries.id = origin_stops.itinerary_id
          JOIN stops AS destination_stops
            ON itineraries.id = destination_stops.itinerary_id
          JOIN hubs AS origin_hubs
            ON origin_hubs.id = origin_stops.hub_id
          JOIN hubs AS destination_hubs
            ON destination_hubs.id = destination_stops.hub_id
          JOIN nexuses AS origin_nexuses
            ON origin_nexuses.id = origin_hubs.nexus_id
          JOIN nexuses AS destination_nexuses
            ON destination_nexuses.id = destination_hubs.nexus_id
          LEFT OUTER JOIN hub_truck_type_availabilities AS origin_hub_truck_type_availabilities
            ON origin_hubs.id = origin_hub_truck_type_availabilities.hub_id
          LEFT OUTER JOIN hub_truck_type_availabilities AS destination_hub_truck_type_availabilities
            ON destination_hubs.id = destination_hub_truck_type_availabilities.hub_id
          LEFT OUTER JOIN truck_type_availabilities AS origin_truck_type_availabilities
            ON origin_hub_truck_type_availabilities.truck_type_availability_id =
               origin_truck_type_availabilities.id
          LEFT OUTER JOIN truck_type_availabilities AS destination_truck_type_availabilities
            ON destination_hub_truck_type_availabilities.truck_type_availability_id =
               destination_truck_type_availabilities.id
          WHERE itineraries.id IN (:itinerary_ids)
          AND   origin_stops.index < destination_stops.index
          AND (
            origin_truck_type_availabilities.id IS NULL
            OR (
              origin_truck_type_availabilities.load_type      = :load_type
              AND   origin_truck_type_availabilities.carriage = 'pre'
            )
          )
          AND (
            destination_truck_type_availabilities.id IS NULL
            OR (
              destination_truck_type_availabilities.load_type      = :load_type
              AND   destination_truck_type_availabilities.carriage = 'on'
            )
          )
          GROUP BY origin_stops.id, destination_stops.id
        "
      end

      def raw_query_without_truck_types
        "
          SELECT
            itineraries.id                AS itinerary_id,
            itineraries.name              AS itinerary_name,
            itineraries.mode_of_transport AS mode_of_transport,
            origin_stops.id               AS origin_stop_id,
            destination_stops.id          AS destination_stop_id,
            origin_hubs.id                AS origin_hub_id,
            destination_hubs.id           AS destination_hub_id,
            origin_hubs.name              AS origin_hub_name,
            destination_hubs.name         AS destination_hub_name,
            origin_nexuses.id             AS origin_nexus_id,
            destination_nexuses.id        AS destination_nexus_id,
            origin_nexuses.name           AS origin_nexus_name,
            destination_nexuses.name      AS destination_nexus_name,
            origin_nexuses.latitude       AS origin_latitude,
            origin_nexuses.longitude      AS origin_longitude,
            destination_nexuses.latitude  AS destination_latitude,
            destination_nexuses.longitude AS destination_longitude
          FROM itineraries
          JOIN stops AS origin_stops
            ON itineraries.id = origin_stops.itinerary_id
          JOIN stops AS destination_stops
            ON itineraries.id = destination_stops.itinerary_id
          JOIN hubs AS origin_hubs
            ON origin_hubs.id = origin_stops.hub_id
          JOIN hubs AS destination_hubs
            ON destination_hubs.id = destination_stops.hub_id
          JOIN nexuses AS origin_nexuses
            ON origin_nexuses.id = origin_hubs.nexus_id
          JOIN nexuses AS destination_nexuses
            ON destination_nexuses.id = destination_hubs.nexus_id
          WHERE itineraries.id IN (:itinerary_ids)
          AND   origin_stops.index < destination_stops.index
        "
      end
    end
  end
end
