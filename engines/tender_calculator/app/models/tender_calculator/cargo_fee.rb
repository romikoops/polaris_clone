# frozen_string_literal: true

module TenderCalculator
  class CargoFee
    attr_reader :fee, :cargo

    def initialize(fee:, cargo:)
      @fee = fee
      @cargo = cargo
    end

    def amount
      calculator_klass = TenderCalculator::RateBasis::Calculator.const_get(fee.rate_basis.camelize)
      calculator_klass.new(fee: fee, cargo: cargo).amount
    end
  end
end
