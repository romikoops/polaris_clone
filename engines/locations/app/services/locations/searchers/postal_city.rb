# frozen_string_literal: true

module Locations
  module Searchers
    class PostalCity < Locations::Searchers::Base
      def location
        primary_target || fallback
      end

      private

      def primary_target
        @primary_target ||= if terms.blank?
          postal_location
        else
          locations_name&.location
        end
      end

      def fallback
        @fallback ||= (search_fallback || geolocation_fallback) if point
      end

      def postal_location
        @postal_location ||= Locations::Location.find_by(name: postal_code, country_code: country_code.downcase)
      end

      def postal_code
        @postal_code ||= data[:postal_code]
      end

      def locations_name
        @locations_name ||= searching_locations_name || locode_name_fallback
      end

      def searching_locations_name
        @searching_locations_name ||= if postal_location.present?
          Locations::Finders::PostalCode.data(
            data: { postal_bounds: postal_location.bounds, terms: terms }
          )
        else
          Locations::Name.search(terms.first).results.first
        end
      end

      def geolocation_fallback
        @geolocation_fallback ||= Locations::Location.where("admin_level > 5").where.not(id: postal_location&.id).smallest_contains(point: point).first
      end

      def locode_name_fallback
        @locode_name_fallback ||= Locations::Name.search(terms.first.split(",").first).results.find(&:locode)
      end

      def search_fallback
        @search_fallback ||= Locations::Searchers::City.data(data: {
          terms: terms,
          country_code: country_code,
          lat: point.y,
          lon: point.x
        })
      end

      def point
        @point ||= locations_name&.point || super
      end
    end
  end
end
