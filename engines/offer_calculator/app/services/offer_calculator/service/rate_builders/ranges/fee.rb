# frozen_string_literal: true

module OfferCalculator
  module Service
    module RateBuilders
      module Ranges
        class Fee
          MODIFIER_LOOKUP = OfferCalculator::Service::RateBuilders::Lookups::MODIFIER_LOOKUP
          SHIPMENT_LEVEL_RATE_BASES = OfferCalculator::Service::RateBuilders::Lookups::SHIPMENT_LEVEL_RATE_BASES
          MODIFIERS_BY_RATE_BASIS = OfferCalculator::Service::RateBuilders::Lookups::MODIFIERS_BY_RATE_BASIS

          NoRateFound = Class.new(StandardError)

          def initialize(measure:, modifier:, request:)
            @measure = measure
            @modifier = modifier
            @request = request
          end

          def fee
            OfferCalculator::Service::RateBuilders::Fee.new(inputs: fee_inputs).tap do |tapped_fee|
              tapped_fee.components = components
            end
          rescue NoRateFound
            persist_errors
            raise_exception
          end

          private

          attr_reader :measure, :modifier, :request

          delegate :result_set, to: :request

          def raise_exception
            load_meterage_exceeded = target_ranges.find { |target_range| target_range.error == OfferCalculator::Errors::LoadMeterageExceeded }

            raise load_meterage_exceeded.error if load_meterage_exceeded.present?

            raise target_ranges.first.error
          end

          def persist_errors
            service_name = service.name
            carrier_name = service.carrier.name
            target_ranges.each do |target_range|
              Journey::Error.create(
                result_set: result_set,
                code: target_range.error.new.code,
                service: service_name,
                carrier: carrier_name,
                mode_of_transport: "truck_carriage",
                property: "load_meterage",
                limit: target_range.max_value
              )
            end
          end

          def components
            target_rates.map do |target_rate|
              update_trucking_rate_metadata(target_rate: target_rate)
              OfferCalculator::Service::RateBuilders::FeeComponent.new(
                value: target_rate.monetized_value,
                modifier: MODIFIERS_BY_RATE_BASIS.keys.find { |key| MODIFIERS_BY_RATE_BASIS[key].include?(target_rate.rate_basis) },
                base: target_rate.base
              )
            end
          end

          def fee_inputs
            raise NoRateFound if target_rates.empty?

            OfferCalculator::Service::RateBuilders::FeeInputs.new(
              charge_category: charge_category,
              rate_basis: rate_basis,
              min_value: first_rate.monetized_min_value,
              max_value: first_rate.monetized_max_value,
              measures: measure,
              targets: targets
            )
          end

          def target_rates
            target_ranges.map(&:rate).compact
          end

          def errors
            target_ranges.map(&:error).compact.uniq
          end

          def targets
            SHIPMENT_LEVEL_RATE_BASES.include?(rate_basis) ? [] : measure.cargo_units
          end

          def charge_category
            @charge_category ||= ::Legacy::ChargeCategory.from_code(
              organization_id: object.organization.id,
              code: "trucking_#{measure.cargo_class}"
            )
          end

          def rate_basis
            first_rate.rate_basis
          end

          def first_rate
            @first_rate ||= target_rates.first
          end

          def target_ranges
            @target_ranges ||= MODIFIER_LOOKUP[modifier.to_sym].map do |modifier_key|
              OfferCalculator::Service::RateBuilders::Ranges::Finder.new(range: ranges[modifier_key], key: modifier_key, measure: measure)
            end
          end

          def update_trucking_rate_metadata(target_rate:)
            code_for_matching = lcl? ? "trucking_lcl" : charge_category.code
            object.breakdowns
              .select { |breakdown| breakdown.code == code_for_matching }
              .each do |breakdown|
              next if breakdown.data.blank?

              breakdown.data[modifier].select! do |range|
                range[target_rate.min_key].to_d == target_rate.range_min && range[target_rate.max_key].to_d == target_rate.range_max
              end
            end
          end

          def lcl?
            measure.load_type == "cargo_item"
          end

          def ranges
            object.result["rates"]
          end

          def service
            @service ||= measure.service
          end

          def object
            @object ||= measure.object
          end
        end
      end
    end
  end
end
