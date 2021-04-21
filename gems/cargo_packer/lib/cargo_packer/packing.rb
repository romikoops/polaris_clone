# frozen_string_literal: true

module CargoPacker
  class Packing
    attr_reader :container, :items
    attr_accessor :spaces, :placements, :weight

    def initialize(weight:, container:, items: [], spaces: [], placements: [])
      @spaces = spaces
      @placements = placements
      @weight = weight
      @container = container
      @items = items
    end

    def valid?
      items.length == placements.length
    end

    def load_meters
      (placements.select(&:base?).sum(&:area) / container.load_meterage_divisor).round(4)
    end
  end
end
