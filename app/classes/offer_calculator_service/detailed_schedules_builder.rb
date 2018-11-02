# frozen_string_literal: true

require_relative 'charge_calculator'

module OfferCalculatorService
  class DetailedSchedulesBuilder < Base
    def perform(schedules, trucking_data, user)
      detailed_schedules = grouped_schedules(schedules: schedules).map do |_key, result_schedules|
        grand_total_charge = ChargeCalculator.new(
          schedule:      result_schedules.first,
          trucking_data: trucking_data,
          shipment:      @shipment,
          user:          user
        ).perform
        next if grand_total_charge.nil?

        quote = grand_total_charge.deconstruct_tree_into_schedule_charge.deep_symbolize_keys
        next if invalid_quote?(quote: quote)

        {
          quote: grand_total_charge.deconstruct_tree_into_schedule_charge.deep_symbolize_keys,
          schedules: result_schedules.map(&:to_detailed_hash),
          meta: meta(schedule: result_schedules.first)
        }
      end

      compacted_detailed_schedules = detailed_schedules.compact
      raise ApplicationError::NoSchedulesCharges if compacted_detailed_schedules.empty?

      detailed_schedules_with_service_level_count(detailed_schedules: compacted_detailed_schedules)
    end

    private

    def detailed_schedules_with_service_level_count(detailed_schedules:)
      filtered_detailed_schedules = detailed_schedules.dup

      detailed_schedule_chunks = filtered_detailed_schedules.chunk do |detailed_schedule|
        [
          detailed_schedule.dig(:meta, :carrier_name),
          detailed_schedule.dig(:meta, :origin_hub),
          detailed_schedule.dig(:meta, :destination_hub)
        ]
      end

      detailed_schedule_chunks.each do |_, detailed_schedule_chunk|
        service_levels = detailed_schedule_chunk.map do |detailed_schedule|
          detailed_schedule.dig(:meta, :service_level)
        end

        detailed_schedule_chunk.each do |detailed_schedule|
          detailed_schedule[:meta][:service_level_count] = service_levels.count
        end
      end

      filtered_detailed_schedules
    end

    def meta(schedule:)
      {
        mode_of_transport: schedule.mode_of_transport,
        name: schedule.trip.itinerary.name,
        service_level: schedule.vehicle_name,
        carrier_name: schedule.carrier_name,
        origin_hub: schedule.origin_hub,
        tenant_vehicle_id: schedule.trip.tenant_vehicle_id,
        itinerary_id: schedule.trip.itinerary_id,
        destination_hub: schedule.destination_hub,
        charge_trip_id: schedule.trip_id
      }
    end

    def grouped_schedules(schedules:)
      schedules.group_by do |schedule|
        "#{schedule.mode_of_transport}_#{schedule.vehicle_name}_#{schedule.carrier_name}"
      end
    end

    def invalid_quote?(quote:)
      quote.dig(:total, :value).blank? ||
        quote.dig(:total, :value).to_i.zero? ||
        !quote.dig(:cargo, :value).nil?
    end
  end
end
