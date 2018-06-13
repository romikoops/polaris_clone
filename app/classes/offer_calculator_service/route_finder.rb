# frozen_string_literal: true
# require "#{Rails.root}/app/non_activerecord_models/route.rb"
module OfferCalculatorService
  class RouteFinder < Base
    def exec(hubs)
      tenant_itineraries = @shipment.tenant.itineraries
      routes_attributes = tenant_itineraries.ids_with_route_stops_for(
        hubs[:origin].ids, hubs[:destination].ids
      )

      raise ApplicationError::NoRoute if routes_attributes.nil?
      routes_attributes.map { |attributes| Route.new(attributes) }
    end
  end
end
