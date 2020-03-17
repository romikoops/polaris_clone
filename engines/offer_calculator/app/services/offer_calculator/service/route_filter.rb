# frozen_string_literal: true

module OfferCalculator
  module Service
    class RouteFilter < Base
      def perform(routes)
        return routes unless should_apply_filter?(routes)

        filtered_routes = routes.select do |route|
          valid_for_route?(route: route)
        end

        raise OfferCalculator::Calculator::InvalidRoutes if filtered_routes.empty?

        filtered_routes
      end

      private

      def tenant_max_dimensions_bundles
        query = { tenant_id: @shipment.tenant_id }
        query[:aggregate] = true if @shipment.aggregated_cargo
        Legacy::MaxDimensionsBundle.where(query)
      end

      def should_apply_filter?(routes)
        !routes.empty? && !@shipment.cargo_units.first.is_a?(Legacy::Container)
      end

      def valid_for_route?(route:)
        if @shipment.aggregated_cargo.present?
          valid_for_mode_of_transport?(cargo: @shipment.aggregated_cargo, route: route, aggregate: true)
        else
          @shipment.cargo_items.all? do |cargo_item|
            valid_for_mode_of_transport?(cargo: cargo_item, route: route, aggregate: false)
          end
        end
      end

      def valid_for_mode_of_transport?(cargo:, route:, aggregate:)
        mode_of_transport = route.mode_of_transport
        cargo.chargeable_weight = cargo.calc_chargeable_weight(mode_of_transport)
        max_dimensions = target_max_dimension(route: route)
        exceeded_dimensions = validate_cargo_dimensions(
          max_dimensions: max_dimensions,
          cargo: cargo,
          aggregate: aggregate
        )
        cargo.chargeable_weight = nil

        exceeded_dimensions.empty?
      end

      def validate_cargo_dimensions(max_dimensions:, cargo:, aggregate:)
        dimension_map = if aggregate.present?
                          Legacy::AggregatedCargo::AGGREGATE_DIMENSION_MAP
                        else
                          Legacy::CargoItem::DIMENSIONS.each_with_object({}) do |dim, hash|
                            hash[dim] = dim
                          end
                        end
        dimension_map.reject do |attribute, validating|
          dimension_exceeds?(value: cargo[attribute], limit: max_dimensions[validating])
        end
      end

      def dimension_exceeds?(value:, limit:)
        value <= limit
      end

      def target_max_dimension(route:)
        args = {
          carrier_id: route.carrier_id,
          tenant_vehicle_id: route.tenant_vehicle_id,
          mode_of_transport: route.mode_of_transport
        }
        mot_filtered_max_dimensions = tenant_max_dimensions_bundles.exists?(args.slice(:mode_of_transport))
        args[:mode_of_transport] = 'general' if mot_filtered_max_dimensions.blank?
        bundle = tenant_max_dimensions_bundles.find_by(args)
        bundle ||= tenant_max_dimensions_bundles.find_by(args.except(:tenant_vehicle_id))
        bundle || tenant_max_dimensions_bundles.find_by(args.slice(:mode_of_transport))
      end
    end
  end
end
