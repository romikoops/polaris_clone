# frozen_string_literal: true

module OfferCalculator
  module Service
    module Measurements
      class Unit < OfferCalculator::Service::Measurements::Base
        delegate :quantity, to: :cargo

        def volumetric_weight
          Measured::Weight.new(cbm_ratio || 0, "kg").scale(total_volume.value)
        end

        def dynamic_volumetric_weight
          [
            volumetric_weight,
            total_weight
          ].max
        end

        def load_meterage_weight
          @load_meterage_weight ||= determine_singular_load_meterage_weight
        end

        def trucking_chargeable_weight_by_stacked_area
          items_per_stack = (TRUCKING_CONTAINER_HEIGHT / cargo.height.value).floor
          num_stacks = (quantity / items_per_stack.to_d).ceil
          stacked_area = cargo.area.scale(num_stacks)
          load_meter_var = stacked_area.scale(1 / LOAD_METERAGE_AREA_DIVISOR)
          Measured::Weight.new(load_meter_var.value * load_meterage_ratio, "kg")
        end
      end
    end
  end
end
