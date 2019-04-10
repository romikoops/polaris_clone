# frozen_string_literal: true

module Locations
  class LocationSeeder
    MultipleResultsFound = Class.new(StandardError)

    def self.seeding(*terms)
      name = Locations::NameFinder.seeding(
        terms,
        fields: %i(name display_name postal_code),
        limit: 1,
        match: :word_middle,
        operator: 'or'
      )
      return nil unless name

      return name.location if name.location

      Locations::LocationSeeder.find_location_for_point(lat: name.point.y, lon: name.point.x)
    end

    def self.seeding_with_postal_code(postal_code:, country_code:, terms:)
      postal_location = Locations::Location.find_by(name: postal_code, country_code: country_code)
      return nil unless postal_location

      return postal_location unless terms.present?

      name = Locations::NameFinder.find_in_postal_code(postal_bounds: postal_location.bounds, terms: terms)

      return name.location if name.present? && name.location

      return nil if name.nil?

      location = Locations::Location.smallest_contains(lat: name.point.y, lon: name.point.x).first
      return location unless location.nil?

      Locations::LocationSeeder.find_in_city(
        terms: terms,
        country_code: country_code,
        point: postal_location.bounds.point
      )
    end

    def self.find_location_for_point(lat:, lon:)
      city = Locations::Location
                        .contains(lat: lat, lon: lon)
                        .where('admin_level > 3')
                        .where('admin_level < 8')
                        .order(admin_level: :desc)
                        .first
      return city if city

      Locations::Location.smallest_contains(lat: lat, lon: lon).first
    end

    def self.seeding_with_locode(locode:)
      name = Locations::Name.find_by(locode: locode)
      return nil unless name
      return name.location if name.location

      Locations::Location.smallest_contains(lat: name.point.y, lon: name.point.x).first
    end

    def self.find_in_city(terms:, country_code:, point:)
      city = Locations::Location.contains(lat: point.y, lon: point.x).where('admin_level > 5').order(:admin_level).first
      return nil unless city

      name = Locations::NameFinder.find_in_postal_code(postal_bounds: city.bounds, terms: terms)
      return nil unless name

      Locations::Location.smallest_contains(lat: name.point.y, lon: name.point.x).first
    end
  end
end
