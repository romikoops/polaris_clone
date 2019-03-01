# frozen_string_literal: true

# require "#{Rails.root}/app/non_activerecord_models/route.rb"
module OfferCalculatorService
  class RouteFinder < Base
    def perform(hubs)
      tenant_itinerary_ids = @shipment.tenant.itineraries.ids
      routes_attributes = Route.attributes_from_hub_and_itinerary_ids(
        hubs[:origin].ids, hubs[:destination].ids, tenant_itinerary_ids
      )

      raise ApplicationError::NoRoute if routes_attributes.nil?

      routes_attributes.map { |attributes| Route.new(attributes) }
    end
  end
end
