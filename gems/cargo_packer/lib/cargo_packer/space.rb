# frozen_string_literal: true

module CargoPacker
  class Space
    attr_reader :dimensions, :position

    def initialize(dimensions:, position:)
      @dimensions = dimensions
      @position = position
    end

    delegate :width, :length, :height, to: :dimensions
  end
end
