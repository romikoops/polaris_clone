# frozen_string_literal: true

module ChargeCalculator
  module Calculators
    class Flat < Base
      def result(amount:, **_args)
        amount
      end
    end
  end
end
