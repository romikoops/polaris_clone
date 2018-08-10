# frozen_string_literal: true

module OfferCalculatorService
  class QuoteRouteBuilder < Base
    def perform(routes)
      @routes = routes
      build_route_objs
    end

    private

    def build_route_objs
      @routes.map do |route|
        @route = route
        Schedule.new(attributes.merge(id: SecureRandom.uuid))
      end
    end

    def attributes
      oute_obj = @route.as_json
      origin_hub = hub = Stop.find(@route.origin_stop_id).hub
      destination_hub = hub = Stop.find(@route.destination_stop_id).hub
      itinerary = Itinerary.find(@route.itinerary_id)
      tenant_vehicle = TenantVehicle.find_by(
        name: "standard",
        mode_of_transport: @route.mode_of_transport,
        tenant_id: itinerary.tenant_id
      )
      
      faux_trip = itinerary.trips.create!(tenant_vehicle_id: tenant_vehicle.id)
      {
        origin_hub_id: origin_hub.id,
        destination_hub_id: destination_hub.id,
        origin_hub_name: origin_hub.name,
        destination_hub_name: destination_hub.name,
        eta: nil,
        etd: nil,
        closing_date: nil,
        trip_id: faux_trip.id,
        mode_of_transport: @route.mode_of_transport,
        vehicle_name:      'standard'
      }
    end

  end
end
