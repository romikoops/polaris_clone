# frozen_string_literal: true

module OfferCalculator
  module Service
    module Measurements
      module Engines
        class Base
          TRUCKING_CONTAINER_HEIGHT = 2.60
          LOAD_METERAGE_AREA_DIVISOR = 2.4

          attr_reader :object

          delegate :cargo_class, :load_type, :cbm_ratio, :load_meterage_ratio, :load_meterage_limit,
            :section, :load_meterage_type, :type, :km, :load_meterage_hard_limit, :load_meterage_stacking, to: :object

          def determine_singular_load_meterage_weight
            return volumetric_weight if load_meterage_ratio.blank?
            return load_meterage_by_area if !stackable? && area_limit_violated

            over_limit = height_limit_violated || area_limit_violated

            over_limit ? load_meterage_by_area : volumetric_weight
          end

          def lcl?
            load_type == "cargo_item"
          end

          def load_meterage_by_area
            [
              trucking_chargeable_weight_by_area,
              total_weight,
              volumetric_weight
            ].max
          end

          def height_limit_violated
            return false unless dimensions_required?

            load_meterage_type == "height_limit" && check_load_meter_limit(amount: height.value)
          end

          def area_limit_violated
            return false unless dimensions_required?

            load_meterage_type == "area_limit" && check_load_meter_limit(amount: area_for_load_meters)
          end

          def consolidated_load_meterage_type
            scope.dig("consolidation", "trucking")&.key(true)
          end

          def check_load_meter_limit(amount:)
            return false if load_meterage_limit.blank?

            past_limit = amount > load_meterage_limit
            raise OfferCalculator::Errors::LoadMeterageExceeded if load_meterage_hard_limit && past_limit

            past_limit
          end

          def area_for_load_meters
            stackable? && load_meterage_stacking ? stacked_area.value : total_area.value
          end

          def stowage_factor
            factor = total_volume.value / total_weight.convert_to(:t).value
            Measured::StowageFactor.new(factor.round(6), "m3/t")
          end

          def trucking_chargeable_weight_by_area
            ldm_value = area_for_load_meters / LOAD_METERAGE_AREA_DIVISOR * load_meterage_ratio
            Measured::Weight.new(ldm_value, "kg")
          end
        end
      end
    end
  end
end
