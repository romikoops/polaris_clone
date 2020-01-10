# frozen_string_literal: true

module OfferCalculator
  module Service
    class RouteFinder < Base
      def perform(hubs)
        tenant_itinerary_ids = @shipment.tenant.itineraries.where(sandbox: @sandbox).ids
        routes_attributes = OfferCalculator::Route.attributes_from_hub_and_itinerary_ids(
          hubs[:origin].ids, hubs[:destination].ids, tenant_itinerary_ids
        )

        raise OfferCalculator::Calculator::NoRoute if routes_attributes.nil?

        routes_attributes.map { |attributes| Route.new(attributes) }
      end
    end
  end
end
