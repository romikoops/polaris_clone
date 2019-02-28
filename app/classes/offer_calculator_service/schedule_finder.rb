# frozen_string_literal: true

module OfferCalculatorService
  class ScheduleFinder < Base
    def perform(routes, raw_delay_in_days, hubs)
      delay_in_days = sanitized_delay_in_days(raw_delay_in_days)
      binding.pry
      Schedule.from_routes(routes, current_etd_in_search(hubs), delay_in_days, @shipment.load_type)
    end

    private

    def current_etd_in_search(hubs)
      trucking_time = longest_trucking_time(hubs).seconds
      @shipment.trucking['pre_carriage']['trucking_time_in_seconds'] = [trucking_time, 129_600].max if trucking_time != 0
      @shipment.desired_start_date + trucking_time
    end

    def longest_trucking_time(hubs)
      return 0 unless @shipment.has_pre_carriage?

      hubs_by_distance = @shipment.pickup_address.furthest_hubs(hubs[:origin])

      hubs_by_distance.each do |hub|
        google_directions = GoogleDirections.new(
          @shipment.pickup_address.lat_lng_string,
          hub.lat_lng_string,
          @shipment.desired_start_date.to_i
        )

        driving_time = google_directions.driving_time_in_seconds
        return google_directions.driving_time_in_seconds_for_trucks(driving_time) if driving_time
      end
    rescue GoogleDirections::NoDrivingTime => e
      Raven.capture_exception(e)
      raise ApplicationError::NoTruckingTime
    end

    def sanitized_delay_in_days(raw_delay_in_days)
      raw_delay_in_days.try(:to_i) || default_delay_in_days
    end

    def default_delay_in_days
      60
    end
  end
end
