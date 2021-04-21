# frozen_string_literal: true

module CargoPacker
  class Placement
    attr_reader :dimensions, :position, :item

    def initialize(dimensions:, position:, item:, stackable:)
      @dimensions = dimensions
      @position = position
      @item = item
      @stackable = stackable
    end

    delegate :width, :length, :height, :area, to: :dimensions
    delegate :base?, to: :position
    delegate :weight, to: :item

    def stackable?
      @stackable
    end
  end
end
