# frozen_string_literal: true

module ExcelDataServices
  module Extractors
    class TenantVehicle < ExcelDataServices::Extractors::Base
      def frame_data
        Legacy::TenantVehicle.left_joins(:carrier)
          .where(organization_id: Organizations.current_id, mode_of_transport: modes_of_transport)
          .select(
            "tenant_vehicles.id as tenant_vehicle_id,
            tenant_vehicles.name AS service,
            carriers.code AS carrier_code,
            mode_of_transport"
          )
      end

      def join_arguments
        args = { "service" => "service", "mode_of_transport" => "mode_of_transport" }
        args["carrier_code"] = "carrier_code" unless frame["carrier_code"].all?(&:blank?)
        args
      end

      def modes_of_transport
        frame["mode_of_transport"].uniq.to_a
      end

      def frame_types
        { "tenant_vehicle_id" => :object }
      end
    end
  end
end
