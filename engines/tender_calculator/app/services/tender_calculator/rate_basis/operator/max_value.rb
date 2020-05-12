# frozen_string_literal: true

module TenderCalculator
  module RateBasis
    module Operator
      class MaxValue < Base
        def amount
          fees.map(&:amount).max
        end
      end
    end
  end
end
