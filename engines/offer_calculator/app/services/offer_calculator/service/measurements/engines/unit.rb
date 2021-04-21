# frozen_string_literal: true

module OfferCalculator
  module Service
    module Measurements
      module Engines
        class Unit < OfferCalculator::Service::Measurements::Engines::Base
          delegate :quantity, :total_weight, :height, :width, :length, :total_volume, :id,
            :consolidated?, :stackable?, :cargo_item?, :volume, :weight, :valid?, :dimensions_required?, to: :cargo_unit

          def initialize(cargo_unit:, scope:, object:)
            @cargo_unit = cargo_unit
            @scope = scope
            @object = object
            @stackability = stackable?
            super()
          end

          attr_reader :cargo_unit, :scope, :object

          def cargo_units
            [cargo_unit]
          end

          alias applicable_units cargo_units

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
            area.scale(stack_count)
          end

          def area
            Measured::Area(width.value * length.value, "m2")
          end

          def total_area
            area.scale(quantity)
          end

          private

          def items_per_stack
            @items_per_stack = (TRUCKING_CONTAINER_HEIGHT / cargo_unit.height.value).floor
          end

          def stack_count
            @stack_count = (quantity / items_per_stack.to_d).ceil
          end
        end
      end
    end
  end
end
