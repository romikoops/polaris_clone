# frozen_string_literal: true

module Api
  module Routing
    class GeoRoutingService < Api::Routing::RoutingService
      def perform
        itineraries_nexuses(target_index: index)
      end

      private

      def itineraries
        itineraries_from_lat_lng
      end
    end
  end
end
