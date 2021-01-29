# frozen_string_literal: true

module OfferCalculator
  module Service
    module Validations
      class CargoItemValidationService < OfferCalculator::Service::Validations::CargoValidationService
        def perform
          cargo_units.each do |cargo_unit|
            validate_cargo(cargo_unit: cargo_unit)
            handle_error_expansion(cargo_unit: cargo_unit)
          end

          validate_aggregate
          expand_aggregate
          errors
        end

        private

        def handle_error_expansion(cargo_unit:)
          cargo_errors = errors.select { |error| error.id == cargo_unit.id }

          return if cargo_errors.empty?

          volume_error = cargo_errors.find { |error| error.attribute == :volume }

          expand_attr_errors(units: [cargo_unit], attributes: VOLUME_DIMENSIONS, error: volume_error) if volume_error
        end

        def expand_attr_errors(units:, attributes:, error:)
          combinations = units.to_a.product(attributes)
          combinations.each do |cargo_unit, attribute|
            next if errors.any? { |match_error| match_error.matches?(cargo: cargo_unit, attr: attribute) }

            errors << OfferCalculator::Service::Validations::Error.new(
              id: cargo_unit.id || SecureRandom.uuid,
              message: error.message,
              attribute: attribute,
              limit: error.limit,
              section: "cargo_item",
              code: error.code
            )
          end
        end

        def expand_aggregate
          return if aggregate_errors.empty?

          expand_aggregate_volume
          expand_aggregate_chargeable
          expand_aggregate_payload
        end

        def expand_aggregate_volume
          volume_error = aggregate_errors.find { |error| error.attribute == :volume }
          return unless volume_error && errors.find { |error| error.attribute == :volume }.blank?

          expand_attr_errors(units: cargo_units, attributes: VOLUME_DIMENSIONS, error: volume_error)
        end

        def expand_aggregate_chargeable
          chargeable_error = aggregate_errors.find { |error| error.attribute == :chargeable_weight }
          return unless chargeable_error && errors.find { |error| error.attribute == :chargeable_weight }.blank?

          expand_attr_errors(units: cargo_units, attributes: STANDARD_ATTRIBUTES, error: chargeable_error)
        end

        def expand_aggregate_payload
          payload_error = aggregate_errors.find { |error| error.attribute == :payload_in_kg }
          return unless payload_error && errors.find { |error| error.attribute == :payload_in_kg }.blank?

          handle_aggregate_payload_expansion
        end

        def handle_aggregate_payload_expansion
          payload_error = aggregate_errors.find { |error| error.attribute == :payload_in_kg }

          return if payload_error.blank?

          cargo_units.each do |cargo_unit|
            next if errors.any? { |error| error.matches?(cargo: cargo_unit, attr: :payload_in_kg) }

            errors << OfferCalculator::Service::Validations::Error.new(
              id: cargo_unit.id || SecureRandom.uuid,
              message: payload_error.message,
              attribute: :payload_in_kg,
              limit: payload_error.limit,
              section: "cargo_item",
              code: 4007
            )
          end
        end

        def validate_aggregate
          aggregate_max_dimensions = filtered_max_dimensions(aggregate: true).where(cargo_class: "lcl")

          keys_for_aggregate_validation.each do |attribute|
            validate_attribute(
              max_dimensions: aggregate_max_dimensions,
              id: "aggregate",
              attribute: attribute,
              measurement: measured_request.send(CARGO_DIMENSION_LOOKUP[attribute]),
              cargo: nil
            )
          end

          validate_attribute(
            max_dimensions: aggregate_max_dimensions,
            id: "aggregate",
            attribute: :chargeable_weight,
            measurement: measured_request.chargeable_weight,
            cargo: nil
          )
        end

        def keys_for_aggregate_validation
          AGGREGATE_ATTRIBUTES.reject do |key|
            cargo_units.all? { |cargo| cargo.send(CARGO_DIMENSION_LOOKUP[key]).value.zero? }
          end
        end

        def conversion_ratio
          pricings.order(wm_rate: :desc).first.wm_rate
        end

        def validation_attributes
          STANDARD_ATTRIBUTES
        end
      end
    end
  end
end
