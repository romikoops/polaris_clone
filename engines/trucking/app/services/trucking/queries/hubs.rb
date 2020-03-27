# frozen_string_literal: true

module Trucking
  module Queries
    class Hubs < ::Trucking::Queries::Base
      def perform
        find_hubs_from_truckings
      end

      private

      def find_hubs_from_truckings
        distance_based_hubs | other_hubs
      end

      def distance_based_hubs
        return [] if distance_hubs.blank?

        distance_hubs.joins(truckings: :location)
                     .where(trucking_location_where_statement, trucking_location_conditions_binds)
      end

      def other_hubs
        ::Legacy::Hub.where(tenant_id: @tenant_id).joins(:truckings)
                     .merge(truckings_for_locations)
      end
    end
  end
end
