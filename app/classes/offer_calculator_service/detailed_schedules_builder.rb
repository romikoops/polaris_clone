# frozen_string_literal: true

require_relative "charge_calculator"

module OfferCalculatorService
  class DetailedSchedulesBuilder < Base
    def perform(schedules, trucking_data, user)
      sorted_schedules = sort_schedules(schedules)
      detailed_schedules = []
      sorted_schedules.each do |_key, schedules|
        grand_total_charge =
          ChargeCalculator.new(
            schedule:      schedules.first,
            trucking_data: trucking_data,
            shipment:      @shipment,
            user:          user
          ).perform
        result = {
          quote: grand_total_charge.deconstruct_tree_into_schedule_charge,
          schedules: schedules.map(&:to_detailed_hash),
          meta: {
            mode_of_transport: schedules.first.mode_of_transport,
            name: schedules.first.trip.itinerary.name,
            service_level: schedules.first.vehicle_name,
            carrier_name: schedules.first.carrier_name,
            origin_hub: schedules.first.origin_hub,
            destination_hub: schedules.first.destination_hub
          }
        }
        next if result[:quote].dig(:total, :value).blank?
        
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
