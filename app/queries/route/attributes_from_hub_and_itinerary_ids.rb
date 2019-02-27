# frozen_string_literal: true

module Queries
  module Route
    class AttributesFromHubAndItineraryIds
      def initialize(args = {})
        @origin_hub_ids      = args[:origin_hub_ids]      || args['origin_hub_ids']
        @destination_hub_ids = args[:destination_hub_ids] || args['destination_hub_ids']
        @itinerary_ids       = args[:itinerary_ids]       || args['itinerary_ids']
      end

      def perform
        sanitized_query = ApplicationRecord.public_sanitize_sql([raw_query, binds])

        ApplicationRecord.connection.exec_query(sanitized_query).to_a
      end

      private

      def binds
        {
          origin_hub_ids: @origin_hub_ids,
          destination_hub_ids: @destination_hub_ids,
          itinerary_ids: @itinerary_ids
        }
      end

      def raw_query
        "
          WITH itineraries_with_stops AS (
            SELECT
              destination_stops.itinerary_id AS itinerary_id,
              origin_stops.id                AS origin_stop_id,
              destination_stops.id           AS destination_stop_id
            FROM (
              SELECT id, itinerary_id, index
              FROM stops
              WHERE hub_id IN (:origin_hub_ids)
            ) as origin_stops
            JOIN (
              SELECT id, itinerary_id, index
              FROM stops
              WHERE hub_id IN (:destination_hub_ids)
            ) as destination_stops
            ON origin_stops.itinerary_id = destination_stops.itinerary_id
            WHERE origin_stops.index < destination_stops.index
          )
          SELECT
            itineraries.id                             AS itinerary_id,
            itineraries.mode_of_transport              AS mode_of_transport,
            itineraries_with_stops.origin_stop_id      AS origin_stop_id,
            itineraries_with_stops.destination_stop_id AS destination_stop_id
          FROM itineraries
          JOIN itineraries_with_stops ON itineraries.id = itineraries_with_stops.itinerary_id
          WHERE itineraries.id IN (:itinerary_ids)
        "
      end
    end
  end
end
