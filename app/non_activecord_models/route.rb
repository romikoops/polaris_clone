# frozen_string_literal: true

Dir["#{Rails.root}/app/queries/route/*.rb"].each { |file| require file }

class Route
  include ActiveModel::Model
  include Queries::Route

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

    query = FullAttributesFromItineraryIds.new(
      itinerary_ids: itinerary_ids,
      options:       options
    )

    route_hashes = query.perform
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
    AttributesFromHubAndItineraryIds.new(
      origin_hub_ids:      origin_hub_ids,
      destination_hub_ids: destination_hub_ids,
      itinerary_ids:       itinerary_ids
    ).perform
  end

  private

  def self.detailed_hash_from_attributes(attributes, options)
    {
      itinerary_id:      attributes["itinerary_id"],
      itinerary_name:    attributes["itinerary_name"],
      mode_of_transport: attributes["mode_of_transport"],
      origin:            hash_from_attributes(attributes, "origin", options),
      destination:       hash_from_attributes(attributes, "destination", options)
    }
  end

  def self.hash_from_attributes(attributes, target, options)
    attribute_names = %i(stop_id hub_id hub_name nexus_id nexus_name latitude longitude country)
    attribute_names << :truck_types if options[:with_truck_types]
    attribute_names.each_with_object({}) do |attribute_name, obj|
      obj[attribute_name] = attributes["#{target}_#{attribute_name}"] || ""
      obj[attribute_name] = obj[attribute_name].split(",") if attribute_name == :truck_types
    end
  end
end
