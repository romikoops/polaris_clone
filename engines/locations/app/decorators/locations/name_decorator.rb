# frozen_string_literal: true

module Locations
  class NameDecorator < SimpleDelegator
    def geojson
      Locations::LocationBounds.bounds(osm_id)
    end

    def lat_lng
      { lat: point.x, lng: point.y}
    end
  end
end
