# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Extractors
      class TenantVehicle < ExcelDataServices::V2::Extractors::Base
        def frame_data
          Legacy::TenantVehicle.where(organization_id: Organizations.current_id, mode_of_transport: modes_of_transport)
            .select(
              "tenant_vehicles.id as tenant_vehicle_id,
              tenant_vehicles.name AS service,
              tenant_vehicles.carrier_id,
              mode_of_transport"
            )
        end

        def join_arguments
          {
            "service" => "service",
            "mode_of_transport" => "mode_of_transport",
            "carrier_id" => "carrier_id"
          }
        end

        def modes_of_transport
          frame["mode_of_transport"].uniq.to_a
        end

        def frame_types
          { "tenant_vehicle_id" => :object, "carrier_id" => :object }
        end

        def error_reason(row:)
          "The service '#{row['service']} (#{row['carrier']})' cannot be found."
        end

        def required_key
          "tenant_vehicle_id"
        end
      end
    end
  end
end
