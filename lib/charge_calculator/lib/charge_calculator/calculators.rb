# frozen_string_literal: true

module ChargeCalculator
  module Calculators
    NoSuchCalculatorError = Class.new(StandardError)

    CALCULATORS = {
      volume: Volume
    }.freeze

    def self.get(key)
      raise NoSuchCalculatorError, "The Calculator '#{key}' doesn't exist" unless CALCULATORS.has_key? key

      CALCULATORS[key].new
    end
  end
end
