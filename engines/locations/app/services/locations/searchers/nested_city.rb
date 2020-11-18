# frozen_string_literal: true

module Locations
  module Searchers
    class NestedCity < Locations::Searchers::Base
      def location
        return nil unless city.present? && locations_name.present?
        return locations_name.location if locations_name.location.present?

        Locations::Location.smallest_contains(point: locations_name.point).first
      end

      private

      def city
        @city ||= Locations::Location
          .contains(point: point)
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
