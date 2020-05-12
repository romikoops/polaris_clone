# frozen_string_literal: true

module TenderCalculator
  module RateBasis
    module Operator
      class Default < Base
        def amount
          fees.first.amount
        end
      end
    end
  end
end
