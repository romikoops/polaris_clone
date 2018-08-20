# frozen_string_literal: true

module ChargeCalculator
  module Calculators
    class PayloadUnit100Kg < Base
      def result(context:, amount:)
        (context.fetch(:payload) / 100.0).ceil * amount * quantity(context)
      end
    end
  end
end
