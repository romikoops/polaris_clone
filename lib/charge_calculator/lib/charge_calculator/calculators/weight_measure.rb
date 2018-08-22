# frozen_string_literal: true

module ChargeCalculator
  module Calculators
    class WeightMeasure < Base
      def result(context:, amount:)
        context[:weight_measure] * amount * quantity(context)
      end
    end
  end
end
