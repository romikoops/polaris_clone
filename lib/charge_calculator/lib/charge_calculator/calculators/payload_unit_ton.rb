# frozen_string_literal: true

module ChargeCalculator
  module Calculators
    class PayloadUnitTon < Base
      def result(context:, amount:)
        (context.fetch(:payload) / 1000.0).ceil * amount * quantity(context)
      end
    end
  end
end
