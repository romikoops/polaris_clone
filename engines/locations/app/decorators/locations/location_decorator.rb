module Locations
  class LocationDecorator < SimpleDelegator
    def geojson
      RGeo::GeoJSON.encode(RGeo::GeoJSON::Feature.new(bounds))
    end

    def description(lang = 'en')
      names.find_by(language: lang)&.description
    end

    def search_result(lang = 'en')
      as_json().merge(
        description: self.description(lang),
        geojson: self.geojson
      )
    end
  end
end