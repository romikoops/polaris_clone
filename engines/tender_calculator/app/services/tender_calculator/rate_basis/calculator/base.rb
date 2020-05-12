# frozen_string_literal: true

module TenderCalculator
  module RateBasis
    module Calculator
      class Base
        attr_reader :fee, :cargo

        def initialize(fee:, cargo:)
          @fee = fee
          @cargo = cargo
        end

        def amount
          value.clamp(min_value, max_value)
        end

        private

        def min_value
          fee.min_amount
        end

        def max_value
          fee.max_amount
        end
      end
    end
  end
end
