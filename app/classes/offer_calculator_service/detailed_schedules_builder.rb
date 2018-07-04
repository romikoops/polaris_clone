# frozen_string_literal: true

require_relative "charge_calculator"

module OfferCalculatorService
  class DetailedSchedulesBuilder < Base
    def perform(schedules, trucking_data, user)
      detailed_schedules = schedules.map do |schedule|
        grand_total_charge =
          ChargeCalculator.new(
            schedule:      schedule,
            trucking_data: trucking_data,
            shipment:      @shipment,
            user:          user
          ).perform

        schedule.total_price = grand_total_charge.price.as_json(only: %i(value currency))
        detailed_schedule = schedule.to_detailed_hash
        next if detailed_schedule.dig(:total_price, "value").zero?

        detailed_schedule
      end

      compacted_detailed_schedules = detailed_schedules.compact
      raise ApplicationError::NoSchedulesCharges if compacted_detailed_schedules.empty?

      compacted_detailed_schedules
    end
  end
end
