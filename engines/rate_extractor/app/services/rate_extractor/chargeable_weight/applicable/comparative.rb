# frozen_string_literal: true

module RateExtractor
  module ChargeableWeight
    module Applicable
      class Comparative < Base
        def chargeable_weight
          if ldm_threshold.present? && total_load_meters >= ldm_threshold
            [units_total_load_meterage_weight, cargo.volumetric_weight, cargo.total_weight].max
          else
            cargo.total_weight
          end
        end

        private

        def total_load_meters
          units_total_load_meterage_weight.value / ldm_ratio
        end

        def units_total_load_meterage_weight
          @units_total_load_meterage_weight ||=
            cargo.units.inject(Measured::Weight.new(0.0, :kg)) { |total, cargo_unit|
              total + unit_ldm_weight(cargo_unit)
            }
        end

        def unit_ldm_weight(cargo_unit)
          "RateExtractor::ChargeableWeight::LoadMeterage::#{ldm_measurement(cargo_unit).camelize}Based"
            .constantize
            .new(rate: section_rate, cargo: cargo_unit)
            .weight
        end

        def ldm_measurement(cargo_unit)
          cargo_unit.stackable ? "stacked_area" : "area"
        end
      end
    end
  end
end
