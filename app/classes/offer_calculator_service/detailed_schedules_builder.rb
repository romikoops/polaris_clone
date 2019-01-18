# frozen_string_literal: true

require_relative 'charge_calculator'

module OfferCalculatorService
  class DetailedSchedulesBuilder < Base
    def perform(schedules, trucking_data, user)
      schedules_by_pricings = grouped_schedules(schedules: schedules,
                                                shipment: @shipment,
                                                user: user).compact
      raise ApplicationError::NoValidPricings if schedules_by_pricings.empty?

      detailed_schedules = schedules_by_pricings.map do |grouped_result|
        grand_total_charge = ChargeCalculator.new(
          trucking_data: trucking_data,
          shipment: @shipment,
          user: user,
          data: grouped_result
        ).perform
        next if grand_total_charge.nil?

        quote = grand_total_charge.deconstruct_tree_into_schedule_charge.deep_symbolize_keys
        next if invalid_quote?(quote: quote)

        {
          quote: grand_total_charge.deconstruct_tree_into_schedule_charge.deep_symbolize_keys,
          schedules: grouped_result[:schedules].map(&:to_detailed_hash),
          meta: meta(
            schedule: grouped_result[:schedules].first,
            shipment: @shipment
          )
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

    def meta(schedule:, shipment:)
      chargeable_weight = if shipment.lcl? && shipment.aggregated_cargo
                            shipment.aggregated_cargo.chargeable_weight
                          elsif shipment.lcl? && !shipment.aggregated_cargo
                            shipment.cargo_items.reduce(0) do |acc, c|
                              acc + c.calc_chargeable_weight(schedule.mode_of_transport)
                            end
                          else
                            0
      end

      {
        mode_of_transport: schedule.mode_of_transport,
        name: schedule.trip.itinerary.name,
        service_level: schedule.vehicle_name,
        carrier_name: schedule.carrier_name,
        origin_hub: schedule.origin_hub,
        tenant_vehicle_id: schedule.trip.tenant_vehicle_id,
        itinerary_id: schedule.trip.itinerary_id,
        destination_hub: schedule.destination_hub,
        charge_trip_id: schedule.trip_id,
        ocean_chargeable_weight: chargeable_weight
      }
    end

    def grouped_schedules(schedules:, shipment:, user:)
      result_to_return = []
      cargo_classes = shipment.aggregated_cargo ? ['lcl'] : shipment.cargo_units.pluck(:cargo_class)
      schedule_groupings = schedules.group_by do |schedule|
        [schedule.mode_of_transport,
         schedule.vehicle_name,
         schedule.carrier_name,
         schedule.load_type,
         schedule.origin_hub_id,
         schedule.destination_hub_id].join('_')
      end
      schedule_groupings.each do |_key, schedules_array|
        schedules_array.sort_by!(&:eta)
        if schedules_array&.any? { |s| s.etd.nil? || s.eta.nil? }
          isQuote = true
          start_date = Date.today
          end_date = start_date + 1.month
        else
          start_date = schedules_array.first.etd
          end_date = schedules_array.last.eta
          isQuote = false
        end
        user_pricing_id = user.role.name == 'agent' ? user.agency_pricing_id : user.id

        # Find the pricings for the cargo classes and effective date ranges then group by cargo_class
        tenant_vehicle_id = schedules_array.first.trip.tenant_vehicle_id
        pricings_by_cargo_class = schedules_array.first.trip.itinerary.pricings
                                                 .where(tenant_vehicle_id: tenant_vehicle_id)
                                                 .for_cargo_class(cargo_classes)
        pricings_by_cargo_class = pricings_by_cargo_class.for_dates(start_date, end_date) if start_date && end_date
        pricings_by_cargo_class = pricings_by_cargo_class
                                  .select do |pricing|
                                    (pricing.user_id == user_pricing_id) || pricing.user_id.nil?
                                  end
                                  .group_by { |pricing| pricing.transport_category_id.to_s }

        # Find the group with the most pricings and create the object to be passed on
        most_diverse_set = pricings_by_cargo_class.values.max_by(&:length)
        other_pricings = pricings_by_cargo_class.values.reject do |pricing_group|
          pricing_group == most_diverse_set
        end.flatten
        if most_diverse_set.nil?
          result_to_return << nil
        else
          most_diverse_set.each do |pricing|
            obj = {
              pricing_ids: {
                pricing.transport_category.cargo_class.to_s => pricing.id
              },
              schedules: if isQuote 
                schedules_array 
              else
                schedules_array.select do |sched|
                  sched.etd < pricing.expiration_date && sched.etd > pricing.effective_date
                end.sort_by!(&:eta)
              end
            }
            other_pricings.each do |other_pricing|
              if other_pricing.effective_date < obj[:schedules].first.etd &&
                 other_pricing.expiration_date > obj[:schedules].last.eta
                obj[:pricing_ids][other_pricing.transport_category.cargo_class] = other_pricing.id
              end
            end
            result_to_return << obj
          end
        end
      end

      result_to_return
    end

    def invalid_quote?(quote:)
      quote.dig(:total, :value).blank? ||
        quote.dig(:total, :value).to_i.zero? ||
        !quote.dig(:cargo, :value).nil?
    end
  end
end
