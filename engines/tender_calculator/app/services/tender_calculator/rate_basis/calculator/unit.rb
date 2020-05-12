# frozen_string_literal: true

module TenderCalculator
  module RateBasis
    module Calculator
      class Unit < Base
        def value
          fee.amount * cargo.quantity
        end
      end
    end
  end
end
