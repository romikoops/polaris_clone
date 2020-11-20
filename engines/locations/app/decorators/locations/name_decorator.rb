# frozen_string_literal: true

module Locations
  class NameDecorator < SimpleDelegator
    def geojson
      return location.geojson if location

      Locations::Location.find_by(osm_id: osm_id)&.geojson
    end

    def lat_lng
      {latitude: point&.y, longitude: point&.x}
    end

    def combined_names
      [postal_code, city, state, country].compact.join(", ")
    end
  end
end
