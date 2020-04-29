# frozen_string_literal: true

module RateExtractor
  module ChargeableWeight
    module LoadMeterage
      class AreaBased < Base
        def weight
          cargo_ldm_weight(measurement: cargo.total_area.value)
        end
      end
    end
  end
end
