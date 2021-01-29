# frozen_string_literal: true

module OfferCalculator
  module Service
    module Validations
      class ContainerValidationService < OfferCalculator::Service::Validations::CargoValidationService
        def perform
          cargo_units.each do |cargo_unit|
            cargo_unit.valid?
            validate_cargo(cargo_unit: cargo_unit)
          end
          errors
        end

        private

        def keys_for_validation(cargo_unit:)
          CONTAINER_ATTRIBUTES.reject { |key| cargo_unit.send(CARGO_DIMENSION_LOOKUP[key])&.value.blank? }
        end

        def validation_attributes
          CONTAINER_ATTRIBUTES
        end
      end
    end
  end
end
