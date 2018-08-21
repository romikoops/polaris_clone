# frozen_string_literal: true

module ChargeCalculator
  module Calculators
    class Base
      def result
        raise NotImplementError
      end

      private

      def quantity(context)
        context.fetch(:quantity, 1)
      end
    end
  end
end
