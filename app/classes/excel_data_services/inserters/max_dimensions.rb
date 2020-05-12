# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class MaxDimensions < ExcelDataServices::Inserters::Base
      def perform
        data.each do |params|
          carrier = find_carrier(name: params.dig(:carrier))
          itinerary = find_itinerary(params.slice(:origin_locode, :destination_locode, :mode_of_transport))
          tenant_vehicle = find_service_level(name: params.dig(:service_level), carrier: carrier)

          update_or_create_max_dimensions_bundle(
            params: params,
            tenant_vehicle: tenant_vehicle,
            carrier: carrier,
            itinerary: itinerary
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

      def find_itinerary(mode_of_transport:, origin_locode: nil, destination_locode: nil)
        return if origin_locode.blank? && destination_locode.blank?

        origin_stops = ::Legacy::Stop.joins(:hub)
                                     .where(hubs: { hub_code: origin_locode, tenant_id: tenant.id })
        destination_stops = ::Legacy::Stop.joins(:hub)
                                          .where(hubs: { hub_code: destination_locode, tenant_id: tenant.id })
        itinerary_ids = origin_stops.pluck(:itinerary_id) | destination_stops.pluck(:itinerary_id)
        ::Legacy::Itinerary.find_by(tenant_id: tenant.id, mode_of_transport: mode_of_transport, id: itinerary_ids)
      end

      def update_or_create_max_dimensions_bundle(params:, carrier:, tenant_vehicle:, itinerary:)
        max_dimension = Legacy::MaxDimensionsBundle.find_or_initialize_by(
          mode_of_transport: params[:mode_of_transport],
          carrier: carrier,
          itinerary: itinerary,
          aggregate: params[:aggregate],
          tenant_vehicle: tenant_vehicle,
          tenant: @tenant,
          cargo_class: params[:cargo_class]
        )
        max_dimension.assign_attributes(
          params.slice(:payload_in_kg, :width, :length, :height, :chargeable_weight)
        )
        add_stats(max_dimension, params[:row_nr])
        max_dimension.save

        max_dimension
      end
    end
  end
end
