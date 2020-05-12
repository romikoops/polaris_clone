# frozen_string_literal: true

module TenderCalculator
  module RateBasis
    module Calculator
      class Shipment < Base
        def amount
          fee.percentage
        end
      end
    end
  end
end
