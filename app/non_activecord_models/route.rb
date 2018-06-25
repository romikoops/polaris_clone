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

  def self.detailed_hashes_from_itinerary_ids(itinerary_ids, options={})
    look_ups = %w(origin_hub destination_hub origin_nexus destination_nexus)
      .each_with_object({}) do |name, obj|
        obj[name] = Hash.new { |h, k| h[k] = [] }
      end

    route_hashes = full_attributes_from_itinerary_ids(itinerary_ids, options)
      .map.with_index do |attributes, i|
        look_ups.each { |name, lookup_hash| lookup_hash[attributes["#{name}_id"]] << i }
        detailed_hash_from_attributes(attributes, options)
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

  def self.detailed_hash_from_attributes(attributes, options)
    {
      itinerary_id:   attributes["itinerary_id"],
      itinerary_name: attributes["itinerary_name"],
      origin:         hash_from_attributes(attributes, "origin"),
      destination:    hash_from_attributes(attributes, "destination")
    }
  end

  def self.full_attributes_from_itinerary_ids(itinerary_ids, options)
    binds = { itinerary_ids: itinerary_ids }
    binds.merge!(options[:with_truck_types]) if options[:with_truck_types].is_a?(Hash)

    raw_query = raw_query(itinerary_ids, options)

    sanitized_query = ApplicationRecord.public_sanitize_sql([raw_query, binds])

    ApplicationRecord.connection.exec_query(sanitized_query).to_a
  end

  def self.raw_query(itinerary_ids, options)
    if options[:with_truck_types]
      raw_query_with_truck_types(itinerary_ids)
    else
      raw_query_without_truck_types(itinerary_ids)
    end
  end

  def self.raw_query_with_truck_types(itinerary_ids, options = {})
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
      JOIN locations AS origin_nexuses
        ON origin_nexuses.id = origin_hubs.nexus_id
      JOIN locations AS destination_nexuses
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

  def self.raw_query_without_truck_types(itinerary_ids)
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
      JOIN locations AS origin_nexuses
        ON origin_nexuses.id = origin_hubs.nexus_id
      JOIN locations AS destination_nexuses
        ON destination_nexuses.id = destination_hubs.nexus_id
      WHERE itineraries.id IN (:itinerary_ids)
      AND   origin_stops.index < destination_stops.index
    "
  end

  def self.hash_from_attributes(attributes, target)
    %i(stop_id hub_id hub_name nexus_id nexus_name latitude longitude truck_types)
      .each_with_object({}) do |attribute, obj|
        obj[attribute] = attributes["#{target}_#{attribute}"] || ""
        obj[attribute] = obj[attribute].split(",") if attribute == :truck_types
      end
  end
end
