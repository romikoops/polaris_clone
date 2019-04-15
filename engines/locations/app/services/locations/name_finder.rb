# frozen_string_literal: true

module Locations
  class NameFinder
    MultipleResultsFound = Class.new(StandardError)

    def self.seeding(*terms)
      results = Locations::Name
                .search(
                  terms,
                  fields: %i(name display_name alternative_names city postal_code),
                  limit: 1,
                  match: :word_middle,
                  operator: 'or'
                )
                .results
      result_with_location = results.select(&:location_id).first
      return result_with_location if result_with_location

      results.first
    end

    def self.find_in_postal_code(postal_bounds:, terms:)
      return nil unless postal_bounds

      postal_coords = if postal_bounds.geometry_type == RGeo::Feature::MultiPolygon
                        postal_bounds.coordinates.map(&:first)
                      else
                        postal_bounds.coordinates
                      end

      postal_coords.each do |coords|
        results = Locations::Name.search(terms, where: { location: { geo_polygon: { points: coords } } }, limit: 1)
                                 .results
        result_with_location = results.select(&:location_id).first
        return result_with_location if result_with_location

        return results.first unless results.empty?
      end

      nil
    end
  end
end
