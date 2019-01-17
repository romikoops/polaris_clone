# frozen_string_literal: true

module Locations
  class LocationDecorator < SimpleDelegator
    def geojson
      RGeo::GeoJSON.encode(RGeo::GeoJSON::Feature.new(bounds))
    end
  end
end
