# frozen_string_literal: true

module OfferCalculator
  module Service
    class QuoteRouteBuilder < OfferCalculator::Service::ScheduleFinder
      def perform(routes, hubs)
        @routes = routes
        current_etd_in_search(hubs)
        build_route_objs
      end

      private

      def build_route_objs
        @routes.map do |route|
          OfferCalculator::Schedule.new(attributes(route: route).merge(id: SecureRandom.uuid))
        end
      end

      def attributes(route:)
        itinerary = Legacy::Itinerary.find(route.itinerary_id)
        origin_hub = Legacy::Stop.find_by(id: route.origin_stop_id, sandbox: @sandbox).hub
        destination_hub = Legacy::Stop.find_by(id: route.destination_stop_id, sandbox: @sandbox).hub
        faux_trip = generate_trip(itinerary: itinerary, tenant_vehicle_id: route.tenant_vehicle_id)

        {
          origin_hub_id: origin_hub.id,
          destination_hub_id: destination_hub.id,
          origin_hub_name: origin_hub.name,
          destination_hub_name: destination_hub.name,
          eta: faux_trip.end_date,
          etd: faux_trip.start_date,
          closing_date: Date.tomorrow,
          trip_id: faux_trip.id,
          mode_of_transport: route.mode_of_transport,
          vehicle_name: faux_trip.tenant_vehicle.name,
          carrier_name: faux_trip.tenant_vehicle&.carrier&.name,
          transshipment: itinerary.transshipment
        }
      end

      def generate_trip(itinerary:, tenant_vehicle_id:)
        transit_time = Legacy::TransitTime.find_by(itinerary: itinerary, tenant_vehicle_id: tenant_vehicle_id)
        itinerary.trips.find_or_create_by!(tenant_vehicle_id: tenant_vehicle_id,
                                           load_type: @shipment.load_type,
                                           start_date: OfferCalculator::Schedule.quote_trip_start_date,
                                           end_date: end_date(transit_time: transit_time),
                                           closing_date: OfferCalculator::Schedule.quote_trip_closing_date,
                                           sandbox: @sandbox)
      end

      def end_date(transit_time:)
        if transit_time
          OfferCalculator::Schedule.quote_trip_start_date + transit_time.duration.days
        else
          OfferCalculator::Schedule.quote_trip_end_date
        end
      end
    end
  end
end
