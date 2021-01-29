# frozen_string_literal: true

module OfferCalculator
  module Service
    class ScheduleFinder < Base
      def perform(routes, raw_delay_in_days, hubs)
        delay_in_days = sanitized_delay_in_days(raw_delay_in_days)
        OfferCalculator::Schedule.from_routes(
          routes,
          current_etd_in_search(hubs),
          delay_in_days,
          request.load_type,
          scope.fetch(:departure_query_type)
        )
      end

      private

      def current_etd_in_search(hubs)
        trucking_time = longest_trucking_time(hubs).seconds
        if trucking_time != 0
          trucking_time_upper_limit = 129_600
          pre_carriage = request.trucking_params["pre_carriage"]
          pre_carriage["trucking_time_in_seconds"] = [trucking_time, trucking_time_upper_limit].max
        end
        request.cargo_ready_date + trucking_time
      end

      def longest_trucking_time(hubs)
        return 0 unless request.has_pre_carriage?

        hubs_by_distance = request.pickup_address.furthest_hubs(hubs[:origin])

        hubs_by_distance.each do |hub|
          google_directions = Trucking::GoogleDirections.new(
            request.pickup_address.lat_lng_string,
            hub.lat_lng_string,
            request.cargo_ready_date.to_i
          )

          driving_time = google_directions.driving_time_in_seconds
          return google_directions.driving_time_in_seconds_for_trucks(driving_time) if driving_time
        end
      rescue ::Trucking::GoogleDirections::NoDrivingTime => e
        Raven.capture_exception(e)
        raise OfferCalculator::Errors::NoDirectionsFound
      end

      def sanitized_delay_in_days(raw_delay_in_days)
        raw_delay_in_days.try(:to_i) || default_delay_in_days
      end

      def default_delay_in_days
        60
      end
    end
  end
end
