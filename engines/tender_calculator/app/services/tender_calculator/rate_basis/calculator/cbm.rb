# frozen_string_literal: true

module TenderCalculator
  module RateBasis
    module Calculator
      class Cbm < Base
        def value
          fee.amount * cargo.total_volume.value
        end
      end
    end
  end
end
