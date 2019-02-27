# frozen_string_literal: true

module OfferCalculatorService
  class QuoteRouteBuilder < Base
    def perform(routes)
      @routes = routes
      build_route_objs
    end

    private

    def build_route_objs
      schedules = []
      @routes.each do |route|
        itinerary = Itinerary.find(route.itinerary_id)
        tenant_vehicle_ids = itinerary.pricings.pluck(:tenant_vehicle_id).uniq
        tenant_vehicle_ids.each { |tv_id| schedules << Schedule.new(attributes(route, itinerary, tv_id).merge(id: SecureRandom.uuid)) }
      end
      schedules
    end

    def attributes(route, itinerary, tenant_vehicle_id)
      origin_hub = Stop.find(route.origin_stop_id).hub
      destination_hub = Stop.find(route.destination_stop_id).hub
      faux_trip = itinerary.trips.find_or_create_by!(tenant_vehicle_id: tenant_vehicle_id)
      {
        origin_hub_id: origin_hub.id,
        destination_hub_id: destination_hub.id,
        origin_hub_name: origin_hub.name,
        destination_hub_name: destination_hub.name,
        eta: nil,
        etd: nil,
        closing_date: nil,
        trip_id: faux_trip.id,
        mode_of_transport: route.mode_of_transport,
        vehicle_name: faux_trip.tenant_vehicle.name,
        carrier_name: faux_trip.tenant_vehicle&.carrier&.name
      }
    end
  end
end
