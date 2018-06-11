# frozen_string_literal: true

module OfferCalculatorService
  class ItineraryFilter < Base
    def exec(itineraries)
      return itineraries unless should_apply_filter?(itineraries)

      filtered_itineraries = itineraries.select do |itinerary|
        all_cargo_items_are_valid_for_itinerary?(itinerary) &&
          @shipment.valid_for_itinerary?(itinerary)
      end

      raise ApplicationError::InvalidItineraries if filtered_itineraries.empty?

      filtered_itineraries
    end

    private

    def should_apply_filter?(itineraries)
      !itineraries.empty? && @shipment.cargo_units.first.is_a?(CargoItem)
    end

    def all_cargo_items_are_valid_for_itinerary?(itinerary)
      @shipment.cargo_items.all? { |cargo_item| cargo_item.valid_for_itinerary?(itinerary) }
    end
  end
end
