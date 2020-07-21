# frozen_string_literal: true

module OfferCalculator
  module Service
    module RateBuilders
      class Truckings < OfferCalculator::Service::RateBuilders::Base
        STANDARD_RANGE_KEYS = OfferCalculator::Service::RateBuilders::Lookups::STANDARD_RANGE_KEYS
        MODIFIER_LOOKUP = OfferCalculator::Service::RateBuilders::Lookups::MODIFIER_LOOKUP
        UNIT_RATE_BASES = OfferCalculator::Service::RateBuilders::Lookups::UNIT_RATE_BASES

        attr_reader :value, :charge_category, :code, :name

        def perform
          measures.children.each do |target_measure|
            @charge_category = trucking_charge_category(target_measure: target_measure)
            @fee_components = []
            create_rates_from_ranges(target_measure: target_measure)
            @fee_arguments = Struct::FeeInputs.new(
              charge_category,
              rate_basis,
              min_value,
              max_value,
              target_measure,
              target
            )
            fee = OfferCalculator::Service::RateBuilders::Fee.new(inputs: @fee_arguments)
            fee.components = @fee_components
            @fees << fee
          end
          super
        end

        private

        attr_reader :rate_basis, :min_value, :max_value, :target

        def modifier
          object.result.dig("modifier")
        end

        delegate :scope, to: :measures

        def trucking_charge_category(target_measure:)
          code = "trucking_#{target_measure.cargo_class}"
          ::Legacy::ChargeCategory.from_code(
            organization_id: object.organization.id,
            code: code
          )
        end

        def exceeded_hard_limit?(rates:, key:, limit:, measure:)
          last_rate = rates.compact.last[key].to_d
          decimal_value = measure.value
          return false if last_rate > decimal_value

          raise OfferCalculator::Errors::LoadMeterageExceeded if decimal_value > last_rate && limit

          true
        end

        def add_fee_to_arguments(rate:, rate_key: modifier, target_measure:)
          @min_value, @max_value = min_max_values(rate: rate)
          @rate_basis = rate.dig("rate_basis")
          @target = determine_target(rate_basis: rate.dig("rate_basis"), target_measure: target_measure)
          return unless rate.dig("value") && rate.dig("currency")

          @fee_components << create_component_for_arguments(rate: rate, rate_key: rate_key)
        end

        def min_max_values(rate:)
          [
            Money.new(rate.fetch("min_value", 0) * 100, rate.dig("rate", "currency")),
            Money.new(rate.fetch("max_value", DEFAULT_MAX) * 100, rate.dig("rate", "currency"))
          ]
        end

        def create_rates_from_ranges(target_measure:)
          MODIFIER_LOOKUP[modifier.to_sym].each do |modifier_key|
            range_handler(modifier_key: modifier_key, target_measure: target_measure)
          end
        end

        def create_component_for_arguments(rate:, rate_key:)
          OfferCalculator::Service::RateBuilders::FeeComponent.new(
            value: Money.new(rate.dig("value") * 100, rate.dig("currency")),
            modifier: fee_component_modifier,
            base: rate.dig("base")
          )
        end

        def fee_component_modifier
          MODIFIERS_BY_RATE_BASIS.find { |_key, value| value.include?(@rate_basis) }.first
        end

        def check_hard_limit(modifier_key:, target_measure:)
          if exceeded_hard_limit?(
            rates: sorted_ranges[modifier_key],
            key: "max_#{modifier_key}",
            limit: scope["hard_trucking_limit"],
            measure: measure_for_modifer(
              modifier_key: modifier_key,
              target_measure: target_measure,
              rate_basis: sorted_ranges[modifier_key].first.dig("rate", "rate_basis")
            )
          )
            sorted_ranges[modifier_key].last
          end
        end

        def trucking_rate_range_finder(min:, max:, measure:)
          (min.to_d..max.to_d).cover?(measure.value)
        end

        def range_handler(modifier_key:, target_measure:)
          rate = rate_from_range(modifier_key: modifier_key, target_measure: target_measure)
          update_trucking_rate_metadata(
            modifier_key: modifier_key,
            min_max: rate.slice("min_#{modifier_key}", "max_#{modifier_key}")
          )
          add_fee_to_arguments(rate: rate["rate"], rate_key: modifier_key, target_measure: target_measure)
        end

        def rate_from_range(modifier_key:, target_measure:)
          rate = check_hard_limit(modifier_key: modifier_key, target_measure: target_measure)
          rate ||= sorted_ranges[modifier_key].find { |range_rate|
            trucking_rate_range_finder(
              min: range_rate["min_#{modifier_key}"],
              max: range_rate["max_#{modifier_key}"],
              measure: measure_for_modifer(
                modifier_key: modifier_key,
                target_measure: target_measure,
                rate_basis: range_rate.dig("rate", "rate_basis")
              )
            )
          }
          rate ||= handle_missed_range(
            range: sorted_ranges[modifier_key],
            min_key: "min_#{modifier_key}",
            max_key: "max_#{modifier_key}",
            value: measure_for_modifer(
              modifier_key: modifier_key,
              target_measure: target_measure,
              rate_basis: sorted_ranges[modifier_key].first.dig("rate", "rate_basis")
            )
          )
          rate
        end

        def measure_for_modifer(modifier_key:, target_measure:, rate_basis:)
          total_value = case modifier_key
                        when "unit_in_kg"
                          target_measure.chargeable_weight
                        else
                          target_measure.send(modifier_key)
          end

          return total_value unless UNIT_RATE_BASES.include?(rate_basis)

          total_value.scale(1.0 / target_measure.quantity)
        end

        def sorted_ranges
          @sorted_ranges ||= object.result["rates"].each_with_object({}) { |(modifier, range), result|
            result[modifier] = range.compact.sort_by { |range_fee| range_fee["max_#{modifier}"].to_d }
          }
        end

        def handle_missed_range(range:, value:, min_key:, max_key:)
          return range.first if value.value < range.first[min_key].to_d
        end

        def update_trucking_rate_metadata(modifier_key:, min_max:)
          code_for_matching = measures.lcl? ? "trucking_lcl" : @charge_category.code
          object.breakdowns
            .select { |breakdown| breakdown.code == code_for_matching }
            .each do |breakdown|
            next if breakdown.data.blank?

            target_ranges = breakdown.data[modifier_key].select { |range|
              range.slice(*min_max.keys) == min_max
            }
            breakdown.data[modifier_key] = target_ranges
          end
        end
      end
    end
  end
end
