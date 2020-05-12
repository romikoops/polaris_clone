# frozen_string_literal: true

module TenderCalculator
  module RateBasis
    module Operator
      class Base
        attr_reader :cargo_rate, :cargo

        def initialize(cargo_rate:, cargo:)
          @cargo_rate = cargo_rate
          @cargo = cargo
        end

        def fees
          @fees ||= cargo_rate.fees.map { |fee| TenderCalculator::CargoFee.new(fee: fee, cargo: cargo) }
        end
      end
    end
  end
end
