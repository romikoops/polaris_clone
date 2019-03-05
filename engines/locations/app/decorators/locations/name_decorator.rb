# frozen_string_literal: true

module Locations
  class NameDecorator < SimpleDelegator
    def geojson
      return location.geojson if location
      Locations::Location.find_by_osm_id(osm_id)&.geojson
    end

    def lat_lng
      { latitude: point.y, longitude: point.x}
    end
  end
end
