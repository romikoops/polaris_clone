# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      class RangeFinder
        attr_reader :fees, :margins, :measure, :scope

        DEFAULT_MAX = 1e12

        def initialize(fees:, margins:, measure:, scope:)
          @fees = fees
          @margins = margins
          @measure = measure
          @scope = scope
        end

        def fee
          raise error if error

          @fee ||= OfferCalculator::Service::Charges::Fee.new(
            rate: rate_of_charge,
            cargo_class: data["cargo_class"],
            charge_category_id: data["charge_category_id"],
            rate_basis: data["rate_basis"],
            base: data["base"].to_d,
            surcharge: Money.from_amount(0, currency),
            minimum_charge: Money.from_amount(data["min"] || 0, currency),
            maximum_charge: Money.from_amount(data["max"] || DEFAULT_MAX, currency),
            range_min: data["range_min"],
            range_max: data["range_max"],
            measure: measure,
            sourced_from_margin: data.key?("operator")
          )
        end

        def range_unit
          data["range_unit"]
        end

        private

        def data
          @data ||= fee_row || margin_fee_row
        end

        def fee_row
          @fee_row ||= if fees.empty? || (hard_limit? && exceeding_range_max?)
            nil
          elsif fee_ranged_row.present?
            fee_ranged_row
          elsif exceeding_range_max?
            max_fee_by_range_max
          end
        end

        def margin_fee_row
          @margin_fee_row ||= RangedRow.new(frame: margins, measure: measure).perform if margins.present?
        end

        def error
          @error ||= [
            exceeded_hard_limit_error,
            missed_in_range_error,
            missing_arguments_error
          ].find(&:present?)
        end

        def fee_ranged_row
          @fee_ranged_row ||= RangedRow.new(frame: fees, measure: measure).perform
        end

        def range_max
          @range_max ||= fees["range_max"].to_a.max || Float::INFINITY
        end

        def max_fee_by_range_max
          @max_fee_by_range_max ||= fees.to_a.max_by { |row| row["range_max"] }
        end

        def hard_limit?
          scope["hard_trucking_limit"]
        end

        def exceeding_range_max?
          @exceeding_range_max ||= measure > range_max
        end

        def exceeded_hard_limit_error
          OfferCalculator::Errors::ExceededRange if hard_limit? && measure > range_max
        end

        def missed_in_range_error
          OfferCalculator::Errors::MissedInRange if fees.present? && fee_row.blank?
        end

        def missing_arguments_error
          ArgumentError.new("Either fees or margins are required.") if fees.empty? && margins.empty?
        end

        def rate_of_charge
          rate = data["rate"]
          case data["rate_basis"]
          when "PERCENTAGE"
            rate.to_d
          else
            Money.from_amount(rate.to_d, currency)
          end
        end

        def currency
          @currency ||= Money::Currency.new(data["currency"])
        end

        class RangedRow
          def initialize(frame:, measure:)
            @frame = frame
            @measure = measure
          end

          attr_reader :frame, :measure

          def perform
            frame[(frame["range_min"] <= measure) & (frame["range_max"] > measure)].to_a.first
          end
        end
      end
    end
  end
end
