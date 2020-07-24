# frozen_string_literal: true

module TenderCalculator
  module RateBasis
    module Calculator
      class Percentage < Base
        def amount
          fee.percentage
        end
      end
    end
  end
end
