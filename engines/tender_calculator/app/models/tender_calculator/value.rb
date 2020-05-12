# frozen_string_literal: true

module TenderCalculator
  class Value < Node
    attr_reader :values

    def initialize(value:)
      @values = [value]
    end
  end
end
