# frozen_string_literal: true

module Api
  module Routing
    module Trucking
      class CounterpartService < Api::Routing::Trucking::Base
        def self.counterpart_availabilities(organization:,
          trucking_details:,
          target:,
          user: nil)
          new(
            organization: organization,
            trucking_details: trucking_details,
            target: target,
            user: user
          ).perform
        end

        def initialize(organization:, trucking_details:, target:, user:)
          super(organization: organization,
                query: query,
                load_type: trucking_details.load_type,
                target: target, user: user)
          coordinates = trucking_details.coordinates
          @lat = coordinates&.dig(:lat)
          @lng = coordinates&.dig(:lng)
          @nexus_id = trucking_details.nexus_id
        end

        def perform
          {
            countryCodes: countries(target_index: index).pluck(:code).map(&:downcase),
            truckTypes: available_truck_types,
            truckingAvailable: available_truck_types.present?
          }
        end

        private

        def available_truck_types
          @available_truck_types ||= truck_types(target_index: index)
        end

        def truck_type_carriage
          carriage == 'pre' ? 'on' : 'pre'
        end
      end
    end
  end
end
