# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      class Margin
        def initialize(operator:, rate:, currency:, source: nil)
          @operator = operator
          @rate = rate
          @currency = currency
          @source = source
        end

        attr_reader :operator, :rate, :currency, :source

        def apply(input_fee:)
          OfferCalculator::Service::Charges::Fee.new(
            rate: apply_margin_to(value: input_fee.rate),
            cargo_class: input_fee.cargo_class,
            charge_category_id: input_fee.charge_category_id,
            rate_basis: input_fee.rate_basis,
            base: input_fee.base,
            measure: input_fee.measure,
            minimum_charge: apply_margin_to(value: input_fee.minimum_charge),
            maximum_charge: apply_margin_to(value: input_fee.maximum_charge),
            surcharge: updated_surcharge(fee: input_fee),
            range_min: input_fee.range_min,
            range_max: input_fee.range_max,
            sourced_from_margin: input_fee.sourced_from_margin,
            applied_margin: source,
            delta: rate,
            parent: input_fee
          )
        end

        private

        def apply_margin_to(value:)
          case operator
          when "%"
            apply_rate_percentage(value: value)
          when "&"
            apply_rate_delta(value: value)
          else
            value
          end
        end

        def apply_rate_delta(value:)
          case value
          when Money
            value + rate_as_money
          else
            value + rate
          end
        end

        def apply_rate_percentage(value:)
          value * (1 + rate)
        end

        def updated_surcharge(fee:)
          if operator == "+"
            fee.surcharge + rate_as_money
          else
            fee.surcharge
          end
        end

        def rate_as_money
          Money.from_amount(rate, currency)
        end
      end
    end
  end
end
