# frozen_string_literal: true

module Api
  module Routing
    module Trucking
      class AvailabilityService < Api::Routing::Trucking::Base
        def self.availability(tenant:, coordinates:, load_type:, target:)
          new(tenant: tenant, load_type: load_type, target: target, coordinates: coordinates).perform
        end

        def initialize(tenant:, load_type:, target:, coordinates:)
          super(tenant: tenant, query: query, load_type: load_type, target: target)
          @lat = coordinates.fetch(:lat)
          @lng = coordinates.fetch(:lng)
        end

        def perform
          {
            truckTypes: available_truck_types,
            truckingAvailable: available_truck_types.present?
          }
        end

        private

        def available_truck_types
          @available_truck_types ||= ::Trucking::Queries::TruckTypes.new(carriage_arguments).perform
        end
      end
    end
  end
end
