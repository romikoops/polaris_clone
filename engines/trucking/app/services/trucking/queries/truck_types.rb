# frozen_string_literal: true

module Trucking
  module Queries
    class TruckTypes < ::Trucking::Queries::Base
      def perform
        find_hubs_from_truckings
      end

      private

      def find_hubs_from_truckings
        truckings_for_query.select(:truck_type).distinct.pluck(:truck_type)
      end
    end
  end
end
