# frozen_string_literal: true

module TenderCalculator
  class Discount
    attr_reader :discount, :cargo

    def initialize(discount:, cargo: nil)
      @discount = discount
      @cargo = cargo
    end

    def amount
      calculator_klass = TenderCalculator::RateBasis::Calculator.const_get(discount.rate_basis.camelize)
      calculator_klass.new(fee: discount, cargo: cargo).amount * -1
    end
  end
end
