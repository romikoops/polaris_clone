# frozen_string_literal: true

module OfferCalculator
  module Service
    module Measurements
      class Cargo
        attr_reader :engine, :weight, :volume, :height, :width, :length, :km, :object,
          :scope, :children
        attr_accessor :stackability

        delegate :cargo_unit, :quantity, :volumetric_weight, :volume_adjusted_weight, :total_weight, :height, :width, :length,
          :total_area, :total_volume, :id, :consolidated?, :stackable?, :stowage_factor, :cargo_item?, :weight,
          :height, :volume, :valid?, :load_meterage_weight, :cargo_class, :load_type, :cbm_ratio,
          :load_meterage_ratio, :load_meterage_limit, :section, :load_meterage_type, :type, :km,
          :load_meterage_hard_limit, :load_meterage_stacking, :stacked_area, :targets,
          :area_for_load_meters, :dynamic_volumetric_weight, :cargo_units,
          :trucking_chargeable_weight_by_area, to: :engine
        delegate :service, to: :object

        def initialize(engine:, scope:, object:)
          @engine = engine
          @scope = scope
          @object = object
          @stackability = stackable?
        end

        def weight_in_tons
          total_weight.convert_to("t")
        end

        def chargeable_weight_in_tons
          chargeable_weight.convert_to("t")
        end

        def shipment
          Measured::Quantity.new(1, "pcs")
        end

        alias bill shipment

        def unit
          Measured::Quantity.new(quantity, "pcs")
        end

        alias container unit

        def weight_measure
          @weight_measure ||= Measured::WeightMeasure.new(
            [volume_adjusted_weight, volumetric_weight].max.convert_to("t").value,
            "t/m3"
          )
        end

        def chargeable_weight
          @chargeable_weight ||=
            if cargo_item?
              lcl_chargeable_weight.max
            else
              total_weight
            end
        end

        def lcl_chargeable_weight
          return [total_weight] if type == "Legacy::LocalCharge"

          [
            volume_adjusted_weight,
            load_meterage_weight,
            volumetric_weight
          ]
        end

        def aggregated?
          cargo_unit.cargo_class == 'aggregated_lcl'
        end

        alias_method :wm, :weight_measure
        alias_method :kg, :chargeable_weight
        alias_method :ton, :chargeable_weight_in_tons
        alias_method :cbm, :total_volume

        private

        def determine_singular_load_meterage_weight
          return volumetric_weight if load_meterage_ratio.blank?
          return load_meterage_by_area if !stackable? && area_limit_violated

          over_limit = height_limit_violated || area_limit_violated

          over_limit ? load_meterage_by_area : volumetric_weight
        end

        def load_meterage_by_area
          [
            trucking_chargeable_weight_by_area,
            total_weight,
            volumetric_weight
          ].max
        end

        def height_limit_violated
          load_meterage_type == "height_limit" && check_load_meter_limit(amount: engine.height.value)
        end

        def area_limit_violated
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
      end
    end
  end
end
