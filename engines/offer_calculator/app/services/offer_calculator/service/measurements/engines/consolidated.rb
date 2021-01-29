# frozen_string_literal: true

module OfferCalculator
  module Service
    module Measurements
      module Engines
        class Consolidated < OfferCalculator::Service::Measurements::Engines::Base
          def initialize(request:, scope:, object:)
            @request = request
            @scope = scope
            @object = object
          end

          attr_reader :request, :scope
          delegate :cargo_units, to: :request

          def id
            cargo_units.pluck(:id).join("/")
          end

          def stackable?
            cargo_units.all?(&:stackable?)
          end

          def consolidated?
            true
          end

          def quantity
            1
          end

          def volumetric_weight
            targets.sum(Measured::Weight.new(0, "kg"), &:volumetric_weight)
          end

          def dynamic_volumetric_weight
            targets.sum(Measured::Weight.new(0, "kg"), &:dynamic_volumetric_weight)
          end

          def stacked_area
            targets.sum(Measured::Area.new(0, "m2"), &:stacked_area)
          end

          def volume
            targets.sum(Measured::Volume.new(0, "m3"), &:total_volume)
          end

          def area
            targets.sum(Measured::Area.new(0, "m2"), &:total_area)
          end

          alias_method :total_volume, :volume
          alias_method :total_area, :area

          def weight
            targets.sum(Measured::Weight.new(0, "kg"), &:total_weight)
          end

          alias_method :total_weight, :weight

          def height
            targets.max_by(&:height).height
          end

          def length
            targets.max_by(&:length).length
          end

          def width
            targets.max_by(&:width).width
          end

          def targets
            @targets ||=
              cargo_units
                .select { |unit| unit.cargo_class == cargo_class }
                .map { |cargo_unit|
                OfferCalculator::Service::Measurements::Cargo.new(
                  engine: cargo_engine_for_unit(cargo_unit: cargo_unit),
                  object: object,
                  scope: scope
                )
              }
          end

          def cargo_engine_for_unit(cargo_unit:)
            OfferCalculator::Service::Measurements::Engines::Unit.new(cargo_unit: cargo_unit, scope: scope, object: object)
          end

          def load_meterage_weight
            @load_meterage_weight ||= case consolidated_load_meterage_type
            when "load_meterage_only"
              consolidated_load_meterage
            when "comparative"
              comparative_load_meterage
            when "calculation"
              determine_singular_load_meterage_weight
            else
              targets.sum(Measured::Weight.new(0, "kg"), &:load_meterage_weight)
            end
          end

          private

          def consolidated_load_meterage
            if check_load_meter_limit(amount: total_area.value) || !stackable?
              @stackability = false

              return targets.sum(Measured::Weight.new(0, "kg"), &:trucking_chargeable_weight_by_area)
            end

            dynamic_volumetric_weight
          end

          def comparative_load_meterage
            total_load_meterage_weight = targets.sum(Measured::Weight.new(0, "kg")) { |child|
              child.trucking_chargeable_weight_by_area
            }

            total_load_meters = total_load_meterage_weight.value / load_meterage_ratio
            if check_load_meter_limit(amount: total_load_meters)
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
end
