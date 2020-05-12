# frozen_string_literal: true

module TenderCalculator
  module RateBasis
    module Operator
      class MinValue < Base
        def amount
          fees.map(&:amount).min
        end
      end
    end
  end
end
