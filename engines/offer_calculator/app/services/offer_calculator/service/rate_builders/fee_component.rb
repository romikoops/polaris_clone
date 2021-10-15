# frozen_string_literal: true

module OfferCalculator
  module Service
    module RateBuilders
      class FeeComponent
        attr_reader :value, :modifier, :base, :percentage

        def initialize(value:, modifier:, percentage: nil, base: nil)
          @value = value
          @modifier = modifier
          @percentage = percentage
          @base = base.to_d
        end
      end
    end
  end
end
