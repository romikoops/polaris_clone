# frozen_string_literal: true

class Route
  include ActiveModel::Model

  attr_accessor :itinerary_id, :mode_of_transport, :origin_stop_id, :destination_stop_id

  def self.group_data_by_attribute(routes)
    routes.each_with_object(Hash.new { |h, k| h[k] = [] }) do |route, obj|
      obj[:itinerary_ids]        << route.itinerary_id
      obj[:origin_stop_ids]      << route.origin_stop_id
      obj[:destination_stop_ids] << route.destination_stop_id
    end
  end

  def self.full_attributes_from_itinerary_ids(itinerary_ids)
    sanitized_query = ApplicationRecord.public_sanitize_sql(["
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
        destination_nexuses.name      AS destination_nexus_name
      FROM itineraries
      JOIN stops AS origin_stops
        ON itineraries.id = origin_stops.itinerary_id
      JOIN stops AS destination_stops
        ON itineraries.id = destination_stops.itinerary_id
      JOIN hubs AS origin_hubs
        ON origin_hubs.id = origin_stops.hub_id
      JOIN hubs AS destination_hubs
        ON destination_hubs.id = destination_stops.hub_id
      JOIN locations AS origin_nexuses
        ON origin_nexuses.id = origin_hubs.nexus_id
      JOIN locations AS destination_nexuses
        ON destination_nexuses.id = destination_hubs.nexus_id
      WHERE itineraries.id IN (?)
      AND   origin_stops.index < destination_stops.index
    ", itinerary_ids])

    ApplicationRecord.connection.exec_query(sanitized_query).to_a
  end

  def self.detailed_hashes_from_itinerary_ids(itinerary_ids)
    look_ups = %w(origin_hub destination_hub origin_nexus destination_nexus)
      .each_with_object({}) do |name, obj|
        obj[name] = Hash.new { |h, k| h[k] = [] }
      end

    route_hashes = full_attributes_from_itinerary_ids(itinerary_ids)
      .map.with_index do |attributes, i|
        look_ups.each { |name, lookup_hash| lookup_hash[attributes["#{name}_id"]] << i }
        {
          itinerary_id:   attributes["itinerary_id"],
          itinerary_name: attributes["itinerary_name"],
          origin:         hash_from_attributes(attributes, "origin"),
          destination:    hash_from_attributes(attributes, "destination")
        }
      end

    {
      route_hashes: route_hashes,
      look_ups:     look_ups
    }
  end

  def self.attributes_from_hub_and_itinerary_ids(origin_hub_ids, destination_hub_ids, itinerary_ids)
    sanitized_query = ApplicationRecord.public_sanitize_sql(["
      WITH itineraries_with_stops AS (
        SELECT
          destination_stops.itinerary_id AS itinerary_id,
          origin_stops.id                AS origin_stop_id,
          destination_stops.id           AS destination_stop_id
        FROM (
          SELECT id, itinerary_id, index
          FROM stops
          WHERE hub_id IN (?)
        ) as origin_stops
        JOIN (
          SELECT id, itinerary_id, index
          FROM stops
          WHERE hub_id IN (?)
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
      WHERE itineraries.id IN (?)
    ", origin_hub_ids, destination_hub_ids, itinerary_ids])

    connection.exec_query(sanitized_query).to_a
  end

  private

  def self.hash_from_attributes(attributes, target)
    %i(stop_id hub_id hub_name nexus_id nexus_name).each_with_object({}) do |attribute, obj|
      obj[attribute] = attributes["#{target}_#{attribute}"]
    end
  end
end
