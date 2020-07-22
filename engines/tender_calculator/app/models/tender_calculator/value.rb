# frozen_string_literal: true

module TenderCalculator
  class Value < Node
    attr_reader :values

    def initialize(value:, rate: nil)
      @values = [value]
      @rate = rate
    end
  end
end
