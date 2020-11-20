# frozen_string_literal: true

module Trucking
  class TruckingPricingDecorator < SimpleDelegator
    def rate
      rates.dig(rates.keys.first, 0, "rate")
    end

    def currency
      rate["currency"]
    end

    def base
      rate["base"]
    end

    def rate_basis
      rate["rate_basis"]
    end
  end
end
