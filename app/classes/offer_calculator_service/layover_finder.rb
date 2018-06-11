# frozen_string_literal: true

module OfferCalculatorService
  class LayoverFinder < Base
    def exec(raw_delay_in_days)
      delay_in_days = sanitized_delay_in_days(raw_delay_in_days)

      schedule_obj = {}
      @itineraries.each do |itin|
        destination_stop = itin.stops.where(hub_id: @destination_hubs).first
        origin_stop = itin.stops.where(hub_id: @origin_hubs).first
        origin_layovers = origin_stop.layovers.where(
          "closing_date > ? AND closing_date < ?",
          @current_etd_in_search,
          @current_etd_in_search + delay_in_days.days
        ).order(:etd).uniq
  
        trip_layovers = origin_layovers.each_with_object({}) do |ol, return_hash|
          return_hash[ol.trip_id] = [
            ol,
            Layover.find_by(trip_id: ol.trip_id, stop_id: destination_stop.id)
          ]
        end
        schedule_obj[itin.id] = trip_layovers unless trip_layovers.empty?
      end
  
      @itineraries_hash = schedule_obj  
    end

    def sanitized_delay_in_days(raw_delay_in_days)
      delay_in_days.try(:to_i) || default_delay_in_days
    end

    def default_delay_in_days
      20
    end
  end
end
