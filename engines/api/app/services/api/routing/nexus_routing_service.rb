# frozen_string_literal: true

module Api
  module Routing
    class NexusRoutingService < Api::Routing::RoutingService
      def perform
        itineraries_nexuses(target_index: index).reorder("name")
      end

      private

      def itineraries
        itineraries_from_nexus_id
      end
    end
  end
end
