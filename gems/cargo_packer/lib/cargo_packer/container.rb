# frozen_string_literal: true

module CargoPacker
  class Container
    attr_reader :dimensions, :load_meterage_divisor

    def initialize(dimensions:, load_meterage_divisor:)
      @dimensions = dimensions
      @load_meterage_divisor = load_meterage_divisor
    end

    delegate :width, :height, :length, :volume, to: :dimensions
  end
end
