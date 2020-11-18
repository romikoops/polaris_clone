# frozen_string_literal: true

module Locations
  module Searchers
    class Point < Locations::Searchers::Base
      def location
        return city if city

        Locations::Location.smallest_contains(point: point).first
      end

      private

      def city
        @city ||= Locations::Location
          .contains(point: point)
          .where("admin_level > 3")
          .where("admin_level < 8")
          .order(admin_level: :desc)
          .first
      end
    end
  end
end
