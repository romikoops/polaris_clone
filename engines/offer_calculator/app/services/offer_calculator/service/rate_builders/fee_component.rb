# frozen_string_literal: true

module OfferCalculator
  module Service
    module RateBuilders
      class FeeComponent
        DEFAULT_BASE = 1e-6

        attr_reader :value, :modifier, :base

        def initialize(value:, modifier:, base: DEFAULT_BASE)
          @value = value
          @modifier = modifier
          @base = sanitized_base(input: base)
        end

        private

        def sanitized_base(input:)
          if input.nil? || input.to_d.zero?
            DEFAULT_BASE
          else
            input.to_d
          end
        end
      end
    end
  end
end
