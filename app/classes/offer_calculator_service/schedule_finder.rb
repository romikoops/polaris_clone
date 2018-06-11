# frozen_string_literal: true

module OfferCalculatorService
  class ScheduleFinder < Base
    def exec(routes, raw_delay_in_days)
      delay_in_days = sanitized_delay_in_days(raw_delay_in_days)
      Schedule.from_routes(routes, current_etd_in_search, delay_in_days)
    end

    private

    def current_etd_in_search
      @shipment.selected_day + longest_trucking_time.seconds + 3.days
    end

    def longest_trucking_time
      return 0 unless @shipment.has_pre_carriage?

      google_directions = GoogleDirections.new(
        @shipment.pickup_address.lat_lng_string,
        @shipment.pickup_address.furthest_hub(@origin_hubs).lat_lng_string,
        @shipment.planned_pickup_date.to_i
      )

      driving_time = google_directions.driving_time_in_seconds
      google_directions.driving_time_in_seconds_for_trucks(driving_time)
    rescue StandardError
      raise ApplicationError::NoTruckingTime
    end

    def sanitized_delay_in_days(raw_delay_in_days)
      raw_delay_in_days.try(:to_i) || default_delay_in_days
    end

    def default_delay_in_days
      20
    end
  end
end
