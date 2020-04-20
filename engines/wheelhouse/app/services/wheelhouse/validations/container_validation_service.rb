# frozen_string_literal: true

module Wheelhouse
  module Validations
    class ContainerValidationService < Wheelhouse::Validations::CargoValidationService
      def perform
        cargo.units.each do |cargo_unit|
          cargo_unit.valid?
          validate_cargo(cargo_unit: cargo_unit)
        end
        errors
      end

      private

      def keys_for_validation(cargo_unit:)
        CONTAINER_ATTRIBUTES.reject { |key| cargo_unit.send(CARGO_DIMENSION_LOOKUP[key]).value.zero? }
      end

      def validation_attributes
        CONTAINER_ATTRIBUTES
      end
    end
  end
end
