# frozen_string_literal: true

module ChargeCalculator
  module Calculators
    class ChargeablePayload < Base
      def result(context:, amount:)
        context.fetch(:chargeable_payload) * amount * quantity(context)
      end
    end
  end
end
