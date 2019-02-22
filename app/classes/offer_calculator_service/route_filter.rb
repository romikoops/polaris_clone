# frozen_string_literal: true

module OfferCalculatorService
  class RouteFilter < Base
    def perform(routes)
      return routes unless should_apply_filter?(routes)

      filtered_routes = routes.select do |route|
        all_cargo_items_are_valid_for_mode_of_transport?(route.mode_of_transport) &&
          @shipment.valid_for_itinerary?(route.itinerary_id)
      end

      raise ApplicationError::InvalidRoutes if filtered_routes.empty?

      filtered_routes
    end

    private

    def should_apply_filter?(routes)
      !routes.empty? && @shipment.cargo_units.first.is_a?(CargoItem)
    end

    def all_cargo_items_are_valid_for_mode_of_transport?(mode_of_transport)
      @shipment.cargo_items.all? do |cargo_item|
        cargo_item.valid_for_mode_of_transport?(mode_of_transport)
      end
    end
  end
end
