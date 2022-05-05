# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      class Component
        NON_MEASURE_RATE_BASES = %w[PER_SHIPMENT PERCENTAGE].freeze
        attr_reader :fee_rows, :margin_rows, :measured_cargo, :range_type

        def initialize(fee_rows:, margin_rows:, measured_cargo:, range_type:)
          @fee_rows = fee_rows
          @margin_rows = margin_rows
          @measured_cargo = measured_cargo
          @range_type = range_type
        end

        def valid?
          fee.present?
        end

        def value
          @value ||= (calculated_value + surcharge).clamp(minimum_charge, maximum_charge)
        end

        def percentage(total:)
          @calculated_value = total * rate
        end

        def measure
          @measure ||= range_type == "percentage" ? 1 : measured_cargo.send(range_type).value.to_f
        end

        delegate :rate, :minimum_charge, :maximum_charge, :surcharge, to: :margined_fee
        delegate :range_min, :range_max, :base, :rate_basis, :charge_category, :percentage?, :sourced_from_margin?, to: :fee

        private

        delegate :margined_fee, :breakdowns, to: :margined_rate

        def margined_rate
          @margined_rate ||= OfferCalculator::Service::Charges::MarginedRate.new(fee: fee, margin_rows: margins_for_rate)
        end

        def calculated_value
          @calculated_value ||= if fee.percentage?
            nil
          elsif base.zero?
            rate * calculation_measure
          else
            rate * (calculation_measure / base).ceil * base
          end
        end

        def calculation_measure
          NON_MEASURE_RATE_BASES.exclude?(rate_basis) ? measure : 1
        end

        def range_finder
          @range_finder ||= OfferCalculator::Service::Charges::RangeFinder.new(fees: fee_rows, margins: margin_rows, measure: measure, scope: measured_cargo.scope)
        end

        delegate :range_unit, :fee, to: :range_finder

        def margins_for_rate
          return margin_rows unless sourced_from_margin?

          margin_rows[(margin_rows["range_max"] != range_max) & (margin_rows["range_min"] != range_min)]
        end
      end
    end
  end
end
