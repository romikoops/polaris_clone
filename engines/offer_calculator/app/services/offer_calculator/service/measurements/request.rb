# frozen_string_literal: true

module OfferCalculator
  module Service
    module Measurements
      class Request
        attr_accessor :stackability

        def initialize(request:, scope:, object:)
          @request = request
          @scope = scope
          @object = object
        end

        attr_reader :request, :scope, :object
        delegate :cargo_class, :service, to: :object
        delegate :cargo_units, :load_type, to: :request

        def quantity
          1
        end

        def weight
          targets.sum(Measured::Weight.new(0, "kg"), &:weight)
        end

        def volume
          targets.sum(Measured::Volume.new(0, "m3"), &:volume)
        end

        def chargeable_weight
          targets.sum(Measured::Weight.new(0, "kg"), &:chargeable_weight)
        end

        def targets
          @targets ||= engines_for_targets.map { |engine|
            OfferCalculator::Service::Measurements::Cargo.new(
              engine: engine,
              object: object,
              scope: scope
            )
          }
        end

        def validation_targets
          units_for_cargo_class.map { |cargo_unit|
            OfferCalculator::Service::Measurements::Cargo.new(
              engine: cargo_engine_for_unit(cargo_unit: cargo_unit),
              object: object,
              scope: scope
            )
          }
        end

        def engines_for_targets
          if scope.dig("consolidation", "cargo", "backend").present? && lcl?
            [cargo_engine_for_consolidation]
          else
            units_for_cargo_class.map do |cargo_unit|
              cargo_engine_for_unit(cargo_unit: cargo_unit)
            end
          end
        end

        def units_for_cargo_class
          cargo_units.select { |unit| unit.cargo_class.include?(cargo_class) }
        end

        def lcl?
          load_type == "cargo_item"
        end

        private

        def cargo_engine_for_unit(cargo_unit:)
          OfferCalculator::Service::Measurements::Engines::Unit.new(
            cargo_unit: cargo_unit, scope: scope, object: object
          )
        end

        def cargo_engine_for_consolidation
          OfferCalculator::Service::Measurements::Engines::Consolidated.new(
            request: request, scope: scope, object: object
          )
        end
      end
    end
  end
end
