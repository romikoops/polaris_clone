# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class MaxDimensions < ExcelDataServices::Inserters::Base
      def perform
        data.each do |params|
          carrier = find_carrier(name: params.dig(:carrier))
          tenant_vehicle = find_service_level(name: params.dig(:service_level), carrier: carrier)

          update_or_create_max_dimensions_bundle(
            params: params,
            tenant_vehicle: tenant_vehicle,
            carrier: carrier
          )
        end

        stats
      end

      private

      def find_carrier(name:)
        return nil if name.blank?

        carrier_from_code(name: name)
      end

      def find_service_level(name:, carrier:)
        return nil if name.blank?

        Legacy::TenantVehicle.find_by(name: name, carrier: carrier, tenant_id: @tenant.id)
      end

      def update_or_create_max_dimensions_bundle(params:, carrier:, tenant_vehicle:)
        max_dimension = Legacy::MaxDimensionsBundle.find_or_initialize_by(
          mode_of_transport: params[:mode_of_transport],
          carrier: carrier,
          aggregate: params[:aggregate],
          tenant_vehicle: tenant_vehicle,
          tenant: @tenant,
          cargo_class: params[:cargo_class]
        )
        max_dimension.assign_attributes(
          params.slice(:payload_in_kg, :dimension_x, :dimension_y, :dimension_z, :chargeable_weight)
        )
        add_stats(max_dimension, params[:row_nr])
        max_dimension.save

        max_dimension
      end
    end
  end
end
