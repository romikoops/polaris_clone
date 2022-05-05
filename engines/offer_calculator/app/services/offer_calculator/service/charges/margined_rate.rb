# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      class MarginedRate
        attr_reader :fee, :margin_rows

        delegate :base, :rate_basis, :charge_category, :currency,
          :minimum_charge, :maximum_charge, :cargo_class, :rate, :surcharge, to: :margined_fee

        def initialize(fee:, margin_rows:)
          @fee = fee
          @margin_rows = margin_rows
        end

        def margined_fee
          @margined_fee ||= margins.inject(fee) do |input_fee, margin|
            margin.apply(input_fee: input_fee)
          end
        end

        private

        def source_from_row(row:)
          return if row["source_type"].blank?

          row["source_type"].constantize.find(row["source_id"])
        end

        def margins
          @margins ||= margin_rows.to_a.map do |margin_row|
            OfferCalculator::Service::Charges::Margin.new(
              operator: margin_row["operator"],
              rate: margin_row["rate"],
              currency: fee.currency,
              source: source_from_row(row: margin_row)
            )
          end
        end
      end
    end
  end
end
