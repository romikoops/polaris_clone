# frozen_string_literal: true

module Locations
  module Searchers
    class Default < Locations::Searchers::Base
      def location
        return nil if coordinates.nil?

        Locations::Location.smallest_contains(point: point).first
      end
    end
  end
end
