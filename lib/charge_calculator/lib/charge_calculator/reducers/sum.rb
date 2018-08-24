# frozen_string_literal: true

module ChargeCalculator
  module Reducers
    class Sum < Base
      def apply(array)
        array.reduce(:+)
      end
    end
  end
end
