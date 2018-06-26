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
end
