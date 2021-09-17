# frozen_string_literal: true

module OfferCalculator
  module Service
    class RouteFilter < Base
      DEFAULT_MOT = "general"

      attr_reader :request, :date_range

      def initialize(request:, date_range:)
        @date_range = date_range
        super(request: request)
      end

      def perform(routes:)
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
        pricings = route_pricings(route: route)
        errors = route_errors(pricings: pricings)
        persist_errors(errors: errors, route: route)
        errors.empty?
      end

      def route_errors(pricings:)
        "OfferCalculator::Service::Validations::#{request.load_type.camelize}ValidationService".constantize
          .errors(
            request: request,
            pricings: pricings,
            final: true
          )
      end

      def route_pricings(route:)
        Pricings::Pricing.joins(:itinerary).where(
          itineraries: {mode_of_transport: route.mode_of_transport},
          itinerary_id: route.itinerary_id,
          tenant_vehicle_id: route.tenant_vehicle_id,
          cargo_class: request.cargo_classes
        ).for_dates(date_range.first, date_range.last)
      end

      def persist_errors(errors:, route:)
        service = Legacy::TenantVehicle.find(route.tenant_vehicle_id)
        errors.each do |error|
          Journey::Error.create(
            query: request.query,
            cargo_unit_id: error.id,
            code: error.code,
            service: service.name,
            carrier: service.carrier&.name,
            mode_of_transport: service.mode_of_transport,
            property: error.attribute,
            limit: error.limit,
            value: error.value
          )
        end
      end
    end
  end
end
