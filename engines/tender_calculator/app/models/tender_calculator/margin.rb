# frozen_string_literal: true

module TenderCalculator
  class Margin
    attr_reader :margin, :cargo

    def initialize(margin:, cargo:)
      @margin = margin
      @cargo = cargo
    end

    def amount
      calculator_klass = TenderCalculator::RateBasis::Calculator.const_get(margin.rate_basis.camelize)
      calculator_klass.new(fee: margin, cargo: cargo).amount
    end
  end
end
