# frozen_string_literal: true

module ChargeCalculator
  module Reducers
    class First < Base
      def apply(array)
        array.first
      end
    end
  end
end
