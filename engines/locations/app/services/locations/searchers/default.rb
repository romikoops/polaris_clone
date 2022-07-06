# frozen_string_literal: true

module Locations
  module Searchers
    class Default < Locations::Searchers::Base
      def location
        return nil if coordinates.nil?

        Locations::Location.where("admin_level > 5")
          .smallest_contains(point: point)
          .first
      end
    end
  end
end
