# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      Fee = Struct.new(:rate,
        :rate_basis,
        :minimum_charge,
        :maximum_charge,
        :surcharge,
        :base,
        :cargo_class,
        :charge_category_id,
        :range_min,
        :range_max,
        :range_unit,
        :measure,
        :sourced_from_margin,
        :applied_margin,
        :delta,
        :parent,
        keyword_init: true) do
        def charge_category
          @charge_category ||= Legacy::ChargeCategory.find(charge_category_id)
        end

        delegate :code, to: :charge_category

        def percentage?
          rate_basis == "PERCENTAGE"
        end

        def sourced_from_margin?
          sourced_from_margin
        end

        def legacy_format
          case code
          when /^trucking_/
            legacy_trucking_format
          else
            legacy_fee_format
          end
        end

        def legacy_fee_format
          {
            rate: rate_as_decimal,
            base: base,
            rate_basis: rate_basis,
            currency: currency.iso_code,
            min: minimum_charge.amount,
            max: maximum_charge.amount,
            range: legacy_range_format
          }
        end

        def legacy_trucking_format
          {
            range_unit => [
              {
                "rate" => {
                  "rate" => rate_as_decimal,
                  "base" => base,
                  "rate_basis" => rate_basis,
                  "currency" => currency.iso_code
                },
                "min_value" => minimum_charge.amount,
                "max_value" => maximum_charge.amount,
                "min_#{range_unit}" => range_min,
                "max_#{range_unit}" => range_max
              }
            ]
          }
        end

        def legacy_range_format
          return [] if range_min.zero? && range_max.infinite?

          [
            {
              rate: rate_as_decimal,
              base: base,
              rate_basis: rate_basis,
              currency: currency.iso_code,
              min: range_min,
              max: range_max
            }
          ]
        end

        def rate_as_decimal
          case rate
          when Money
            rate.amount
          when Numeric
            rate
          end
        end

        delegate :currency, to: :minimum_charge
      end
    end
  end
end
