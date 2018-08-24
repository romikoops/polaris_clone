# frozen_string_literal: true

module ChargeCalculator
  module Calculators
    class Volume < Base
      def result(context:, amount:)
        context[:volume] * amount * quantity(context)
      end
    end
  end
end
