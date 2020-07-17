# frozen_string_literal: true

module OfferCalculator
  module Service
    module Measurements
      class Base
        LOAD_METERAGE_AREA_DIVISOR = 2.4
        TRUCKING_CONTAINER_HEIGHT = 2.60

        attr_reader :cargo, :quantity, :weight, :volume, :height, :width, :length, :km, :object,
          :scope, :children
        attr_accessor :stackability

        delegate :total_weight, :height, :width, :length, :total_area, :total_volume, :id,
          :consolidated?, :stackable?, :stowage_factor, :lcl?, to: :cargo
        delegate :cargo_class, :load_type, :cbm_ratio, :load_meterage_ratio, :load_meterage_limit,
          :section, :load_meterage_type, to: :object

        def initialize(cargo:, scope:, object:, km: 0)
          @cargo = cargo
          @scope = scope
          @object = object
          @km = Measured::Length.new(km, "km")
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

        def unit
          Measured::Quantity.new(quantity, "pcs")
        end

        def weight_measure
          @weight_measure ||= Measured::WeightMeasure.new(
            [total_weight, volumetric_weight].max.convert_to("t").value,
            "t/m3"
          )
        end

        def chargeable_weight
          @chargeable_weight ||=
            if lcl?
              [
                volumetric_weight,
                total_weight,
                load_meterage_weight
              ].max
            else
              total_weight
            end
        end

        def trucking_chargeable_weight_by_area
          ldm_value = total_area.value / LOAD_METERAGE_AREA_DIVISOR * load_meterage_ratio
          Measured::Weight.new(ldm_value, "kg")
        end

        alias wm weight_measure
        alias kg chargeable_weight
        alias ton chargeable_weight_in_tons
        alias cbm total_volume

        private

        def determine_singular_load_meterage_weight
          return volumetric_weight if load_meterage_ratio.blank?
          return load_meterage_by_area unless stackable?

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
          load_meterage_type == "height_limit" && cargo.height.value > load_meterage_limit
        end

        def area_limit_violated
          load_meterage_type == "area_limit" && cargo.total_area.value >= load_meterage_limit
        end

        def consolidated_load_meterage_type
          scope.dig("consolidation", "trucking")&.key(true)
        end
      end
    end
  end
end
