# frozen_string_literal: true

module CargoPacker
  class Dimensions
    attr_reader :width, :length, :height

    NULL_VALUE = BigDecimal("0")

    def initialize(width: NULL_VALUE, length: NULL_VALUE, height: NULL_VALUE)
      @width = width.to_d
      @length = length.to_d
      @height = height.to_d
    end

    def area
      width * length
    end

    def volume
      area * height
    end
  end
end
