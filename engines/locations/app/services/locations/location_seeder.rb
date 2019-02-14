# frozen_string_literal: true

module Locations
  class LocationSeeder
    MultipleResultsFound = Class.new(StandardError)

    def self.seeding(*terms)
      name = Locations::NameFinder.seeding(terms, fields: [:name, :display_name, :postal_code], limit: 1, match: :word_middle, operator: 'or').results.first
      return nil unless name
      return name.location if name.location
      Locations::Location.smallest_contains({lat: name.point.y, lon: name.point.x}).first
    end

    def self.seeding_with_postal_code(postal_code:, country_code:, terms:)
      postal_location = Locations::Location.find_by(name: postal_code, country_code: country_code)
      return nil unless postal_location
      return postal_location unless terms.present?
      name = Locations::NameFinder.find_in_postal_code(postal_bounds: postal_location.bounds, terms: terms)
      return nil unless name
      return name.location if name.location
      Locations::Location.smallest_contains({lat: name.point.y, lon: name.point.x}).first
    end
  end
end
