# frozen_string_literal: true

module RateExtractor
  module ChargeableWeight
    module Applicable
      class Consolidated < Base
        def chargeable_weight
          ldm_weight = "RateExtractor::ChargeableWeight::LoadMeterage::#{ldm_measurement.camelize}Based"
                       .constantize
                       .new(rate: section_rate, cargo: cargo)
                       .weight

          [ldm_weight, cargo.volumetric_weight, cargo.total_weight].max
        end
      end
    end
  end
end
