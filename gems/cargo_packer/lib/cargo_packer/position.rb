# frozen_string_literal: true

module CargoPacker
  class Position < CargoPacker::Dimensions
    def base?
      height.zero?
    end
  end
end
