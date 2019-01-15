# frozen_string_literal: true

module Locations
  class LocationDecorator < SimpleDelegator
    def geojson
      RGeo::GeoJSON.encode(RGeo::GeoJSON::Feature.new(bounds))
    end

    def description(lang: 'en')
      names.find_by(language: lang)&.description
    end

    def postal_code(lang: 'en')
      names.find_by(language: lang)&.postal_code
    end

    def country(lang: 'en')
      names.find_by(language: lang)&.country
    end

    def city(lang: 'en')
      sorted_attributes = %i(
        locality_3
        locality_4
        locality_5
        locality_6
        locality_7
        locality_8
        locality_9
        locality_10
        locality_11
        name
      ).reverse
      name = names.find_by(language: lang)
      result = nil

      sorted_attributes.each do |attr|
        if name[attr]
          result = name[attr]
        end
      end

      result
    end
  end
end
