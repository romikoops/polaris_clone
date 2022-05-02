# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class TransitTime < ExcelDataServices::V4::Extractors::Base
        def frame_data
          Legacy::TransitTime
            .joins(:tenant_vehicle).where(tenant_vehicles: { organization_id: Organizations.current_id, mode_of_transport: modes_of_transport })
            .joins(:itinerary).where(tenant_vehicles: { organization_id: Organizations.current_id, mode_of_transport: modes_of_transport })
            .select(
              "legacy_transit_times.id as transit_time_id,
                legacy_transit_times.tenant_vehicle_id as tenant_vehicle_id,
                legacy_transit_times.itinerary_id as itinerary_id"
            )
        end

        def join_arguments
          {
            "tenant_vehicle_id" => "tenant_vehicle_id",
            "itinerary_id" => "itinerary_id"
          }
        end

        def modes_of_transport
          frame["mode_of_transport"].uniq.to_a
        end

        def frame_types
          { "tenant_vehicle_id" => :object, "itinerary_id" => :object }
        end
      end
    end
  end
end
