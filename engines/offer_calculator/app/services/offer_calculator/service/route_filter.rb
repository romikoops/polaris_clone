# frozen_string_literal: true

module OfferCalculator
  module Service
    class RouteFilter < Base
      DEFAULT_MOT = "general"

      def perform(routes)
        return routes unless should_apply_filter?(routes)

        filtered_routes = routes.select { |route|
          valid_for_route?(route: route)
        }

        raise OfferCalculator::Errors::InvalidRoutes if filtered_routes.empty?

        filtered_routes
      end

      private

      def should_apply_filter?(routes)
        !routes.empty?
      end

      def valid_for_route?(route:)
        "OfferCalculator::Service::Validations::#{shipment.load_type.camelize}ValidationService".constantize
          .errors(
            cargo: quotation.cargo,
            modes_of_transport: [route.mode_of_transport],
            itinerary_ids: [route.itinerary_id],
            tenant_vehicle_ids: [route.tenant_vehicle_id],
            final: true
          ).empty?
      end
    end
  end
end
