# frozen_string_literal: true

module OfferCalculatorService
  class ScheduleFinder < Base
    def perform(routes, raw_delay_in_days, hubs)
      delay_in_days = sanitized_delay_in_days(raw_delay_in_days)
      Schedule.from_routes(routes, current_etd_in_search(hubs), delay_in_days)
    end

    private

    def current_etd_in_search(hubs)
      trucking_time = longest_trucking_time(hubs).seconds
      if trucking_time != 0
        @shipment.trucking["pre_carriage"]["trucking_time_in_seconds"] = [trucking_time, 129600].max
      end
      @shipment.desired_start_date + trucking_time
    end

    def longest_trucking_time(hubs)
      return 0 unless @shipment.has_pre_carriage?
      binding.pry
      google_directions = GoogleDirections.new(
        @shipment.pickup_address.lat_lng_string,
        @shipment.pickup_address.furthest_hub(hubs[:origin]).lat_lng_string,
        @shipment.desired_start_date.to_i
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
