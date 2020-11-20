# frozen_string_literal: true

module RateExtractor
  module ChargeableWeight
    module Applicable
      class Regular < Base
        def chargeable_weight
          cargo.units.inject(Measured::Weight.new(0.0, :kg)) do |total, cargo_unit|
            ldm_weight = "RateExtractor::ChargeableWeight::LoadMeterage::#{ldm_measurement.camelize}Based"
              .constantize
              .new(rate: section_rate, cargo: cargo_unit)
              .weight

            total + [ldm_weight, cargo_unit.volumetric_weight, cargo_unit.total_weight].max
          end
        end
      end
    end
  end
end
