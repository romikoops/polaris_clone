# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      class RangeFeeBuilder
        attr_reader :fee_rows, :margin_rows, :measured_cargo, :range_type

        def initialize(fee_rows:, margin_rows:, measured_cargo:, range_type:)
          @fee_rows = fee_rows
          @margin_rows = margin_rows
          @measured_cargo = measured_cargo
          @range_type = range_type
        end

        def perform
          margined_rate.margined_fee if ranged_fee.present?
        end

        private

        def measure
          @measure ||= range_type == "percentage" ? 1 : measured_cargo.send(range_type).value.to_f
        end

        def margined_rate
          @margined_rate ||= OfferCalculator::Service::Charges::MarginedRate.new(fee: ranged_fee, margin_rows: margins_for_rate)
        end

        def ranged_fee
          @ranged_fee ||= range_finder.fee
        end

        def range_finder
          @range_finder ||= OfferCalculator::Service::Charges::RangeFinder.new(fees: fee_rows, margins: margin_rows, measure: measure, scope: measured_cargo.scope)
        end

        def margins_for_rate
          return margin_rows unless ranged_fee.sourced_from_margin?

          margin_rows[(margin_rows["range_max"] != ranged_fee.range_max) & (margin_rows["range_min"] != ranged_fee.range_min)]
        end
      end
    end
  end
end
