# frozen_string_literal: true

module TenderCalculator
  module RateBasis
    module Calculator
      class Wm < Base
        def value
          fee.amount * cargo.weight_measure.value
        end
      end
    end
  end
end
