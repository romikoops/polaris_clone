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
          OfferCalculator::Schedule.from_trip(faux_trip(route: route))
        end
      end

      def faux_trip(route:)
        itinerary = Legacy::Itinerary.find(route.itinerary_id)
        generate_trip(itinerary: itinerary, tenant_vehicle_id: route.tenant_vehicle_id)
      end

      def generate_trip(itinerary:, tenant_vehicle_id:)
        transit_time = Legacy::TransitTime.find_by(itinerary: itinerary, tenant_vehicle_id: tenant_vehicle_id)
        itinerary.trips.find_or_create_by!(tenant_vehicle_id: tenant_vehicle_id,
                                           load_type: request.load_type,
                                           start_date: start_date,
                                           end_date: end_date(transit_time: transit_time),
                                           closing_date: closing_date)
      end

      def end_date(transit_time:)
        if transit_time
          start_date + [transit_time.duration, 1].max.days
        else
          start_date + OfferCalculator::Schedule::DURATION.days
        end
      end

      def start_date
        @start_date ||= [
          buffer.to_i.days.from_now.beginning_of_day,
          request.cargo_ready_date.beginning_of_day
        ].max
      end

      def closing_date
        @closing_date ||= [
          Time.zone.today.beginning_of_day,
          (start_date - closing_date_buffer.days)
        ].max
      end

      def buffer
        scope[:search_buffer]
      end

      def closing_date_buffer
        scope[:closing_date_buffer]
      end
    end
  end
end
