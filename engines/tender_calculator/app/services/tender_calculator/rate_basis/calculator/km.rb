# frozen_string_literal: true

module TenderCalculator
  module RateBasis
    module Calculator
      class Km < Base
        def value
          fee.amount * cargo.route_distance
        end
      end
    end
  end
end
