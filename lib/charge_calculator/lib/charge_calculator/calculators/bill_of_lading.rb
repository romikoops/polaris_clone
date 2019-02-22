# frozen_string_literal: true

module ChargeCalculator
  module Calculators
    class BillOfLading < Base
      def result(context:, amount:)
        context.fetch(:bills_of_lading, []).count * amount
      end
    end
  end
end
