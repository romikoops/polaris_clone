# frozen_string_literal: true

module Locations
  class NameDecorator < SimpleDelegator
    def geojson
      return location.bounds if location
      Locations::Location.find_by_osm_id(osm_id)&.geojson
    end

    def lat_lng
      { lat: point.y, lng: point.x}
    end
  end
end
