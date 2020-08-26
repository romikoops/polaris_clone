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

        def stacked_area
          cargo.area.scale(stack_count)
        end

        private

        def items_per_stack
          @items_per_stack = (TRUCKING_CONTAINER_HEIGHT / cargo.height.value).floor
        end

        def stack_count
          @stack_count = (quantity / items_per_stack.to_d).ceil
        end
      end
    end
  end
end
