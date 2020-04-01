# frozen_string_literal: true

module Trucking
  module Queries
    class Hubs < ::Trucking::Queries::Base
      def perform
        find_hubs_from_truckings
      end

      private

      def find_hubs_from_truckings
        Legacy::Hub.where(id: distance_based_hub_ids).or(Legacy::Hub.where(id: other_hub_ids)).distinct
      end

      def distance_based_hub_ids
        return [] if distance_hubs.blank?

        distance_hubs.joins(truckings: :location)
                     .where(trucking_location_where_statement, trucking_location_conditions_binds).select(:id)
      end

      def other_hub_ids
        ::Legacy::Hub.where(tenant_id: @tenant_id).joins(:truckings)
                     .merge(truckings_for_locations).select(:id)
      end
    end
  end
end
