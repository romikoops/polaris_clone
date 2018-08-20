# frozen_string_literal: true

module ChargeCalculator
  module Calculators
    class Volume < Base
      def result(context:, amount:)
        basis(context) * amount * quantity(context)
      end

      private

      attr_reader :context, :amount

      def basis(context)
        context[self.class.downcase]
      end

      def quantity(context)
        context.fetch(:quantity, 1)
      end
    end
  end
end
