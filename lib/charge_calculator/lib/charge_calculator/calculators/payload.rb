# frozen_string_literal: true

module ChargeCalculator
  module Calculators
    class Payload < Base
      def result(context:, amount:)
        context.fetch(:payload) * amount * quantity(context)
      end
    end
  end
end
