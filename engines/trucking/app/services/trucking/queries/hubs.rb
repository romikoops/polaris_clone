# frozen_string_literal: true

module Trucking
  module Queries
    class Hubs < ::Trucking::Queries::Base
      def perform
        find_hubs_from_truckings
      end

      private

      def find_hubs_from_truckings
        Legacy::Hub.where(id: truckings_for_query.select(:hub_id).distinct)
      end
    end
  end
end
