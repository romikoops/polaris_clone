# frozen_string_literal: true

module Api
  module Routing
    module Trucking
      class CounterpartService < Api::Routing::Trucking::Base
        def self.counterpart_availabilities(tenant:, coordinates: nil, nexus_id: nil, load_type: nil, target:)
          new(
            tenant: tenant,
            load_type: load_type,
            target: target,
            coordinates: coordinates,
            nexus_id: nexus_id
          ).perform
        end

        def initialize(tenant:, load_type:, target:, coordinates: nil, nexus_id:)
          super(tenant: tenant, query: query, load_type: load_type, target: target)
          @lat = coordinates&.dig(:lat)
          @lng = coordinates&.dig(:lng)
          @nexus_id = nexus_id
        end

        def perform
          {
            countryCodes: country_codes(target_index: index),
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

        def itineraries
          if lat.present? && lng.present?
            itineraries_from_lat_lng
          elsif nexus_id.present?
            itineraries_from_nexus_id
          end
        end
      end
    end
  end
end
