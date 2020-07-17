# frozen_string_literal: true

module OfferCalculator
  module Service
    class RouteFinder < Base
      def self.routes(shipment:, quotation:, hubs:, date_range:)
        new(shipment: shipment, quotation: quotation).perform(hubs: hubs, date_range: date_range)
      end

      def perform(hubs:, date_range:)
        query_data = {
          origin_hub_ids: hubs[:origin].pluck(:id),
          destination_hub_ids: hubs[:destination].pluck(:id)
        }
        routes_attributes = OfferCalculator::Route.attributes_from_hub_and_itinerary_ids(
          date_range: date_range,
          query: query_data,
          shipment: @shipment,
          scope: @scope
        )

        raise OfferCalculator::Errors::NoRoute if routes_attributes.nil?

        routes_attributes.map { |attributes| Route.new(attributes) }
      end
    end
  end
end
