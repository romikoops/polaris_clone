# frozen_string_literal: true

module ChargeCalculator
  module Calculators
    class Base
      def result
        raise NotImplementError
      end

      private

      attr_reader :context, :amount

      def quantity(context)
        context.fetch(:quantity, 1)
      end
    end
  end
end
