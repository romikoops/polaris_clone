# frozen_string_literal: true

module Api
  module Routing
    module Trucking
      class AvailabilityService < Api::Routing::Trucking::Base
        def self.availability(organization:, coordinates:, load_type:, target:)
          new(organization: organization, load_type: load_type, target: target, coordinates: coordinates).perform
        end

        def initialize(organization:, load_type:, target:, coordinates:)
          super(organization: organization, query: query, load_type: load_type, target: target)
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
