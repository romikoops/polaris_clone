# frozen_string_literal: true

module Pdf
  class ChargeableWeightRow
    attr_reader :weight, :volume, :view_type

    def initialize(weight:, volume:, view_type:)
      @weight = weight
      @volume = volume
      @view_type = view_type
    end

    def perform
      case view_type
      when "weight"
        ["weight", weight]
      when "volume"
        ["volume", volume]
      when "both"
        ["both", volume]
      when "dynamic"
        if show_volume
          ["volume", volume]
        else
          ["weight", weight]
        end
      end
    end

    def show_volume
      volume > weight
    end
  end
end
