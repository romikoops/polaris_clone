# frozen_string_literal: true

module RateExtractor
  module ChargeableWeight
    module LoadMeterage
      class LoadMetersBased < Base
        def weight
          load_meters = (cargo.total_area.value / ldm_area_divisor)

          return cargo.weight if load_meters < ldm_threshold

          Measured::Weight.new(load_meters * ldm_ratio, :kg)
        end
      end
    end
  end
end
