# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      Fee = Struct.new(:rate,
        :rate_basis,
        :minimum_charge,
        :maximum_charge,
        :base,
        :cargo_class,
        :charge_category_id,
        :range_min,
        :range_max,
        :sourced_from_margin,
        keyword_init: true) do
        def charge_category
          @charge_category ||= Legacy::ChargeCategory.find(charge_category_id)
        end

        def percentage?
          rate_basis == "PERCENTAGE"
        end

        def sourced_from_margin?
          sourced_from_margin
        end
      end
    end
  end
end
