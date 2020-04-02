# frozen_string_literal: true

module Api
  module Routing
    module Trucking
      class Base < Api::Routing::RoutingService
        private

        attr_reader :tenant, :latlng, :load_type, :nexus_id, :target

        def truck_types(target_index:)
          ::Trucking::TypeAvailability
            .joins(hub_availabilities: :hub)
            .where(
              trucking_hub_availabilities: {
                hub_id: itineraries_hubs(target_index: target_index).select(:id)
              },
              load_type: load_type,
              carriage: truck_type_carriage
            ).select(:truck_type).distinct.pluck(:truck_type)
        end

        def country_codes(target_index:)
          itineraries_nexuses(target_index: target_index).joins(:country)
                                                         .pluck('LOWER(countries.code)')
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
      end
    end
  end
end
