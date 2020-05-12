# frozen_string_literal: true

module TenderCalculator
  module RateBasis
    module Operator
      class SumValues < Base
        def amount
          fees.sum(&:amount)
        end
      end
    end
  end
end
