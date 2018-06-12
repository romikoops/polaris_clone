# frozen_string_literal: true

class Route
  include ActiveModel::Model

  attr_accessor :itinerary_id, :mode_of_transport, :origin_stop_id, :destination_stop_id
end
