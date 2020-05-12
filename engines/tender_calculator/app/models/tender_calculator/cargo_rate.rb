# frozen_string_literal: true

module TenderCalculator
  class CargoRate
    attr_reader :cargo, :cargo_rate

    def initialize(cargo_rate:, cargo: nil)
      @cargo = cargo
      @cargo_rate = cargo_rate
    end

    def value
      operator_klass = TenderCalculator::RateBasis::Operator.const_get(cargo_rate.operator.camelize)
      operator_klass.new(cargo_rate: cargo_rate, cargo: cargo).amount
    end
  end
end
