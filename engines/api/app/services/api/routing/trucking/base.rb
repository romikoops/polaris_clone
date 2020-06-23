# frozen_string_literal: true

module Api
  module Routing
    module Trucking
      class Base < Api::Routing::RoutingService
        private

        attr_reader :tenant, :latlng, :load_type, :nexus_id, :target

        def truck_types(target_index:)
          type_availabilities(target_index: target_index)
            .where(carriage: truck_type_carriage)
            .select(:truck_type).distinct.pluck(:truck_type)
        end

        def type_availabilities(target_index:)
          ::Trucking::TypeAvailability
            .joins(hub_availabilities: :hub)
            .where(
              trucking_hub_availabilities: {
                hub_id: itineraries_hubs(target_index: target_index).select(:id)
              },
              load_type: load_type
            )
        end

        def country_codes(target_index:)
          ::Trucking::Location
            .where(id: trucking_location_ids(target_index: target_index))
            .select(:country_code)
            .distinct
        end

        def index
          target == :origin ? DESTINATION_INDEX : ORIGIN_INDEX
        end

        def counterpart_index
          target == :origin ? ORIGIN_INDEX : DESTINATION_INDEX
        end

        def carriage
          target == :origin ? 'pre' : 'on'
        end

        def truck_type_carriage
          carriage
        end

        def trucking_location_ids(target_index:)
          ::Trucking::Trucking.where(
            tenant_id: legacy_tenant_id,
            hub: itineraries_hubs(target_index: target_index)
          ).select(:location_id)
        end

        def itineraries
          if lat.present? && lng.present?
            itineraries_from_lat_lng
          elsif nexus_id.present?
            itineraries_from_nexus_id
          else
            super
          end
        end
      end
    end
  end
end
