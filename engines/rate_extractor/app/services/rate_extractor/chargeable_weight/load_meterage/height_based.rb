# frozen_string_literal: true

module RateExtractor
  module ChargeableWeight
    module LoadMeterage
      class HeightBased < Base
        def weight
          cargo_ldm_weight(measurement: cargo.height.value)
        end
      end
    end
  end
end
