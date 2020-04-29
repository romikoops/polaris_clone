# frozen_string_literal: true

module RateExtractor
  module ChargeableWeight
    module LoadMeterage
      class StackedAreaBased < Base
        def weight
          items_per_stack = (truck_height / cargo.height.value).floor
          num_stacks = (cargo.quantity / items_per_stack.to_d).ceil
          stacked_area = cargo.area.value * num_stacks

          Measured::Weight.new(stacked_area / ldm_area_divisor * ldm_ratio, :kg)
        end
      end
    end
  end
end
