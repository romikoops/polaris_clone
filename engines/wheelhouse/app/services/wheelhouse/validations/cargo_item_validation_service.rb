# frozen_string_literal: true

module Wheelhouse
  module Validations
    class CargoItemValidationService < Wheelhouse::Validations::CargoValidationService
      def perform
        cargo.units.each do |cargo_unit|
          cargo_unit.valid?
          validate_cargo(cargo_unit: cargo_unit)
          handle_error_expansion(cargo_unit: cargo_unit)
        end
        if cargo.units.length > 1
          validate_aggregate
          expand_aggregate
        end
        errors
      end

      private

      def handle_error_expansion(cargo_unit:)
        cargo_errors = errors.select { |error| error.id == cargo_unit.id }

        return if cargo_errors.empty?

        volume_error = cargo_errors.find { |error| error.attribute == :volume }

        if volume_error
          expand_attr_errors(units: [cargo_unit], attributes: VOLUME_DIMENSIONS, error: volume_error)
        end
      end

      def expand_attr_errors(units:, attributes:, error:)
        combinations = units.to_a.product(attributes)
        combinations.each do |cargo_unit, attribute|
          next if errors.any? { |error| error.matches?(cargo: cargo_unit, attr: attribute) }

          errors << Wheelhouse::Validations::Error.new(
            id: cargo_unit.id,
            message: error.message,
            attribute: attribute,
            limit: error.limit,
            section: 'cargo_item',
            code: error.code
          )
        end
      end

      def expand_aggregate
        return if aggregate_errors.empty?

        chargeable_error = aggregate_errors.find { |error| error.attribute == :chargeable_weight }
        volume_error = aggregate_errors.find { |error| error.attribute == :volume }

        if volume_error
          expand_attr_errors(units: cargo.units, attributes: VOLUME_DIMENSIONS, error: volume_error)
        end

        if chargeable_error
          expand_attr_errors(units: cargo.units, attributes: STANDARD_ATTRIBUTES, error: chargeable_error)
        else
          handle_aggregate_payload_expansion
        end
      end

      def handle_aggregate_payload_expansion
        payload_error = aggregate_errors.find { |error| error.attribute == :payload_in_kg }

        return if payload_error.blank?

        cargo.units.each do |cargo_unit|
          next if errors.any? { |error| error.matches?(cargo: cargo_unit, attr: :payload_in_kg) }

          errors << Wheelhouse::Validations::Error.new(
            id: cargo_unit.id,
            message: payload_error.message,
            attribute: :payload_in_kg,
            limit: payload_error.limit,
            section: 'cargo_item',
            code: 4007
          )
        end
      end

      def validate_aggregate
        aggregate_max_dimensions = filtered_max_dimensions(aggregate: true).where(cargo_class: 'lcl')

        keys_for_aggregate_validation.each do |attribute|
          validate_attribute(
            max_dimensions: aggregate_max_dimensions,
            id: 'aggregate',
            attribute: attribute,
            measurement: cargo.send(CARGO_DIMENSION_LOOKUP[attribute]),
            cargo: cargo
          )
        end
        return unless cargo.units.all?(&:valid?)

        validate_attribute(
          max_dimensions: aggregate_max_dimensions,
          id: 'aggregate',
          attribute: :chargeable_weight,
          measurement: chargeable_weight(object: cargo),
          cargo: cargo
        )
      end

      def keys_for_aggregate_validation
        AGGREGATE_ATTRIBUTES.reject do |key|
          cargo.units.all? { |cargo| cargo.send(CARGO_DIMENSION_LOOKUP[key]).value.zero? }
        end
      end

      def chargeable_weight(object:)
        weight = [object.volume.scale(conversion_ratio).value, object.weight.value].max
        Measured::Weight.new(weight, 'kg')
      end

      def conversion_ratio
        ratio = if modes_of_transport.length == 1
                  Legacy::CargoItem::EFFECTIVE_TONNAGE_PER_CUBIC_METER[modes_of_transport.first]
                else
                  Legacy::CargoItem::EFFECTIVE_TONNAGE_PER_CUBIC_METER.values.max
                end
        ratio ? ratio * 1_000 : DEFAULT_CONVERSION_RATIO
      end

      def validation_attributes
        STANDARD_ATTRIBUTES
      end
    end
  end
end
