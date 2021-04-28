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
        ["weight", weight.round(3)]
      when "volume"
        ["volume", volume.round(3)]
      when "both"
        ["both", volume.round(3)]
      when "dynamic"
        if show_volume
          ["volume", volume.round(3)]
        else
          ["weight", weight.round(3)]
        end
      end
    end

    def show_volume
      volume > weight
    end
  end
end
