# frozen_string_literal: true

module ChargeCalculator
  module Reducers
    class Max < Base
      def apply(array)
        array.max
      end
    end
  end
end
