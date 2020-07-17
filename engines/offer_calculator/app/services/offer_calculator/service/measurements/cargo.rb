# frozen_string_literal: true

module OfferCalculator
  module Service
    module Measurements
      class Cargo < OfferCalculator::Service::Measurements::Base
        attr_accessor :stackability

        def quantity
          1
        end

        def volumetric_weight
          children.sum(Measured::Weight.new(0, "kg"), &:volumetric_weight)
        end

        def dynamic_volumetric_weight
          children.sum(Measured::Weight.new(0, "kg"), &:dynamic_volumetric_weight)
        end

        def load_meterage_weight
          @load_meterage_weight ||=
            if consolidated?
              determine_singular_load_meterage_weight
            else
              determine_consolidated_load_meterage_weight
            end
        end

        def children
          @children ||=
            if scope.dig("consolidation", "cargo", "backend").present? && lcl?
              [OfferCalculator::Service::Measurements::Unit.new(
                cargo: cargo, object: object, scope: scope, km: km.value
              )]
            else
              cargo.units
                .where(cargo_class: ::Cargo::Creator::CARGO_CLASS_LEGACY_MAPPER[cargo_class])
                .map do |cargo_unit|
                OfferCalculator::Service::Measurements::Unit.new(
                  cargo: cargo_unit, object: object, scope: scope, km: km.value
                )
              end
            end
        end

        private

        def determine_consolidated_load_meterage_weight
          case consolidated_load_meterage_type
          when "load_meterage_only"
            consolidated_load_meterage
          when "comparative"
            comparative_load_meterage
          when "calculation"
            determine_singular_load_meterage_weight
          else
            children.sum(Measured::Weight.new(0, "kg"), &:load_meterage_weight)
          end
        end

        def consolidated_load_meterage
          if load_meterage_limit && (total_area.value > load_meterage_limit || !stackable)
            @stackability = false

            return children.sum(Measured::Weight.new(0, "kg"), &:trucking_chargeable_weight_by_area)
          end

          dynamic_volumetric_weight
        end

        def comparative_load_meterage
          total_load_meterage_weight = children.sum(Measured::Weight.new(0, "kg")) { |child|
            if child.stackable?
              child.trucking_chargeable_weight_by_stacked_area
            else
              child.trucking_chargeable_weight_by_area
            end
          }

          total_load_meters = total_load_meterage_weight.value / load_meterage_ratio
          if load_meterage_limit.present? && total_load_meters >= load_meterage_limit
            @stackability = false
            [total_load_meterage_weight, volumetric_weight].max
          else
            volumetric_weight
          end
        end
      end
    end
  end
end
