# frozen_string_literal: true

module Locations
  class NameFinder
    MultipleResultsFound = Class.new(StandardError)

    def self.seeding(*terms)
      Locations::Name.search(terms, fields: [:name, :display_name, :postal_code], limit: 1, match: :word_middle, operator: 'or').results.first
    end

    def self.seeding_with_postal_code(postal_code:, country_code:, terms:)
      postal_bounds = Locations::Location.find_by(name: postal_code, country_code: country_code)&.bounds
      return nil unless postal_bounds
      Locations::Name.search(terms, where: {location: {geo_polygon: {points: postal_bounds.coordinates.first.first}}}, limit: 1).results.first
    end
  end
end
