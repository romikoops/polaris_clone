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
        @fallback ||= locations_name && (geolocation_fallback || search_fallback)
      end

      def postal_location
        @postal_location ||= Locations::Location.find_by(name: postal_code, country_code: country_code)
      end

      def postal_code
        @postal_code ||= data[:postal_code]
      end

      def locations_name
        @locations_name ||= begin
          return nil if postal_location.blank?

          Locations::Finders::PostalCode.data(
            data: {postal_bounds: postal_location.bounds, terms: terms}
          )
        end
      end

      def geolocation_fallback
        @geolocation_fallback ||= Locations::Location.smallest_contains(
          point: locations_name.point
        ).first
      end

      def search_fallback
        @search_fallback ||= Locations::Searchers::City.data(data: {
          terms: terms,
          country_code: country_code,
          lat: locations_name.point.y,
          lon: locations_name.point.x
        })
      end
    end
  end
end
