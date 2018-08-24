# frozen_string_literal: true

module ChargeCalculator
  module Calculators
    class Flat < Base
      def result(context:, amount:)
        amount * quantity(context)
      end
    end
  end
end
