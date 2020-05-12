# frozen_string_literal: true

module TenderCalculator
  module RateBasis
    module Calculator
      class Stowage < Base
        def value
          fee.amount * cargo.stowage_factor.value
        end
      end
    end
  end
end
