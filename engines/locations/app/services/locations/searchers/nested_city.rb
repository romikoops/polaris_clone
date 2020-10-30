# frozen_string_literal: true

module Locations
  module Searchers
    class NestedCity < Locations::Searchers::Base
      def location
        return nil unless city.present? && locations_name.present?
        return locations_name.location if locations_name.location.present?

        Locations::Location.smallest_contains(lat: locations_name.point.y, lon: locations_name.point.x).first
      end

      private

      def city
        @city ||= Locations::Location
          .contains(lat: lat, lon: lon)
          .where("admin_level > 5")
          .order(:admin_level)
          .first
      end

      def locations_name
        @locations_name ||= Locations::Finders::PostalCode.data(
          data: {postal_bounds: city.bounds, terms: terms}
        )
      end
    end
  end
end
