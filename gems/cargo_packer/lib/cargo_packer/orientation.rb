# frozen_string_literal: true

module CargoPacker
  class Orientation
    attr_reader :width, :length, :height

    def initialize(width:, length:, height:)
      @width = width
      @length = length
      @height = height
    end
  end
end
