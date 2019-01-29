# frozen_string_literal: true

module OfferCalculatorService
  class DetailedQuoteBuilder < Base
    def perform(route_objs, trucking_data, user)
      sorted_schedules = sort_schedules(route_objs)
      detailed_schedules = []
      sorted_schedules.each do |_key, schedules|
        charge_schedule = schedules.first
        grand_total_charge = ChargeCalculator.new(
          schedule:      charge_schedule,
          trucking_data: trucking_data,
          shipment:      @shipment,
          user:          user
        ).perform
        next if grand_total_charge.nil?

        result = {
          quote: grand_total_charge.deconstruct_tree_into_schedule_charge,
          schedules: schedules.map(&:to_detailed_hash),
          meta: {
            mode_of_transport: charge_schedule.mode_of_transport,
            name: charge_schedule.trip.itinerary.name,
            service_level: charge_schedule.vehicle_name,
            carrier_name: charge_schedule.carrier_name,
            origin_hub: charge_schedule.origin_hub,
            tenant_vehicle_id: charge_schedule.trip.tenant_vehicle_id,
            itinerary_id: charge_schedule.trip.itinerary_id,
            destination_hub: charge_schedule.destination_hub,
            charge_trip_id: charge_schedule.trip_id
          }
        }
        next if result[:quote].dig(:total, :value).blank? ||
                result[:quote].dig(:total, :value).to_i.zero? ||
                !result[:quote].dig(:cargo, :value).nil?

        detailed_schedules << result
      end

      compacted_detailed_schedules = detailed_schedules.compact
      raise ApplicationError::NoSchedulesCharges if compacted_detailed_schedules.empty?

      compacted_detailed_schedules
    end

    def sort_schedules(schedules)
      results = {}
      schedules.each do |schedule|
        schedule_key = "#{schedule.mode_of_transport}_#{schedule.vehicle_name}_#{schedule.carrier_name}"
        results[schedule_key] = [] unless results[schedule_key]
        results[schedule_key] << schedule
      end
      results
    end
  end
end
