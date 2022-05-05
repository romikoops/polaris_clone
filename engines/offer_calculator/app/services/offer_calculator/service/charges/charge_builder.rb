# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      class ChargeBuilder
        attr_reader :fee_rows, :margin_rows, :measured_cargo, :range_unit

        delegate :quantity, :object, to: :measured_cargo

        def initialize(fee_rows:, margin_rows:, measured_cargo:, range_unit:)
          @fee_rows = fee_rows
          @margin_rows = margin_rows
          @measured_cargo = measured_cargo
          @range_unit = range_unit
        end

        def perform
          range_type_charges.max_by(&:value)
        end

        private

        def range_type_charges
          @range_type_charges ||= range_type_fees.map do |fee|
            OfferCalculator::Service::Charges::Charge.new(
              fee: fee,
              measured_cargo: measured_cargo
            )
          end
        end

        def range_type_fees
          @range_type_fees ||= range_units.filter_map do |range_type|
            OfferCalculator::Service::Charges::RangeFeeBuilder.new(
              fee_rows: fee_rows.filter("range_unit" => range_type),
              margin_rows: margin_rows,
              measured_cargo: measured_cargo,
              range_type: range_type
            ).perform
          end
        end

        def range_units
          @range_units ||= fee_rows["range_unit"].to_a.uniq.presence || [range_unit]
        end
      end
    end
  end
end
