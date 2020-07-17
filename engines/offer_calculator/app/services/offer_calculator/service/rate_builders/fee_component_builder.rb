# frozen_string_literal: true

module OfferCalculator
  module Service
    module RateBuilders
      class FeeComponentBuilder
        STANDARD_RATE_BASES = OfferCalculator::Service::RateBuilders::Lookups::STANDARD_RATE_BASES
        MODIFIERS_BY_RATE_BASIS = OfferCalculator::Service::RateBuilders::Lookups::MODIFIERS_BY_RATE_BASIS

        delegate :object, to: :measures

        def self.components(fee:, measures:)
          new(fee: fee, measures: measures).perform
        end

        def initialize(fee:, measures:)
          @measures = measures
          @fee = fee
        end

        def perform
          fee_values.map do |result|
            OfferCalculator::Service::RateBuilders::FeeComponent.new(
              value: Money.new(result[:value] * 100.0, fee.dig("currency")),
              modifier: result[:modifier_key],
              base: fee.dig("base") || fee.dig("x_base")
            )
          end
        end

        private

        attr_reader :measures, :fee

        def find_modifier_by_rate_basis(rate_basis:)
          MODIFIERS_BY_RATE_BASIS.entries.find { |entry| entry.second.include?(rate_basis) }&.first
        end

        def rate_basis
          @rate_basis ||= ::Pricings::RateBasis.get_internal_key(fee.fetch("rate_basis"))
        end

        def fee_values
          if STANDARD_RATE_BASES.include?(rate_basis)
            [
              {
                value: fee.fetch("value", fee.fetch("rate", 0)).to_d,
                modifier_key: find_modifier_by_rate_basis(rate_basis: rate_basis)
              }
            ]
          elsif rate_basis.match?(/RANGE/)
            [handle_range_fee]
          else
            handle_non_standard_rate_basis
          end
        end

        def handle_non_standard_rate_basis
          dynamic_modifer_keys.map do |modifier_key|
            {value: fee[modifier_key], modifier_key: modifier_key.to_sym}
          end
        end

        def dynamic_modifer_keys
          modifier_rate_basis = rate_basis.dup
          modifier_rate_basis.sub!("CONTAINER", "UNIT") if modifier_rate_basis.include?("CONTAINER")
          modifier_rate_basis.sub!("PER_", "")
            .split("_")
            .map(&:downcase)
        end

        def measure_key
          rate_basis[/PER_(.*)?_RANGE/, 1]&.downcase&.to_sym
        end

        def handle_range_fee
          value, max = case rate_basis
                       when "PER_UNIT_TON_CBM_RANGE"
                         [measures.stowage_factor, false]
                       when /FLAT/
                         [measures.send(measure_key), false]
                       else
                         [measures.send(measure_key), true]
          end
          target = target_in_range(ranges: fee["range"], measure: value, max: max)
          update_range_fee_metadata(key: fee["key"], final_range: target) if target.present?
          build_range_result(target: target)
        end

        def handle_stowage_range(target:)
          if target["ton"]
            {value: target["ton"], modifier_key: :ton}
          elsif target["cbm"]
            {value: target["cbm"], modifier_key: :cbm}
          else
            {value: target.fetch("rate", 0), modifier_key: :shipment}
          end
        end

        def build_range_result(target:)
          case rate_basis
          when "PER_UNIT_TON_CBM_RANGE"
            handle_stowage_range(target: target)
          else
            {
              value: extract_range_value(target: target, key: measure_key),
              modifier_key: rate_basis.match?(/FLAT/) ? :shipment : measure_key
            }
          end
        end

        def extract_range_value(target:, key: "rate")
          target[key] || target["rate"] || target["value"]
        end

        def target_in_range(ranges:, measure:, max: false)
          target = ranges.find { |step|
            Range.new(step["min"], step["max"], true).cover?(measure.value)
          }

          target || (max ? ranges.max_by { |x| x["max"] } : {"rate" => 0})
        end

        def update_range_fee_metadata(key:, final_range:)
          object.breakdowns.select { |breakdown| breakdown.code == key }
            .each do |breakdown|
            next if breakdown.data.blank?

            target_ranges = breakdown.data["range"]
              .select { |range|
              range.slice("min", "max") == final_range.slice("min", "max")
            }
            breakdown.data["range"] = target_ranges
          end
        end
      end
    end
  end
end
