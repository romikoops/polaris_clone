# frozen_string_literal: true

module TenderCalculator
  module RateBasis
    module Calculator
      class Kg < Base
        def value
          fee.amount * cargo.chargeable_weight.value
        end
      end
    end
  end
end
