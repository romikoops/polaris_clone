# frozen_string_literal: true

module Locations
  class LocationBounds
    def self.bounds(osm_id)
      Locations::LocationDecorator.new(Locations::Location.find_by_osm_id(osm_id * -1)).geojson
    end
  end
end
