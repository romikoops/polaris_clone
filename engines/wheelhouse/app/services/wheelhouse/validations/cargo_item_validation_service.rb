# frozen_string_literal: true

module Wheelhouse
  module Validations
    class CargoItemValidationService < Wheelhouse::Validations::CargoValidationService
      def perform
        cargo.units.each do |cargo_unit|
          cargo_unit.valid?
          validate_cargo(cargo_unit: cargo_unit)
        end
        if cargo.units.length > 1
          validate_aggregate
          expand_aggregate
        end
        errors
      end

      private

      def expand_aggregate
        return if aggregate_errors.empty?

        chargeable_error = aggregate_errors.find { |error| error.attribute == :chargeable_weight }
        if chargeable_error
          handle_aggregate_chargeable_weight_expansion(chargeable_error: chargeable_error)
        else
          handle_aggregate_payload_expansion
        end
      end

      def handle_aggregate_payload_expansion
        payload_error = aggregate_errors.first
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

      def handle_aggregate_chargeable_weight_expansion(chargeable_error:)
        combinations = cargo.units.to_a.product(STANDARD_ATTRIBUTES)
        combinations.each do |pairing|
          cargo_unit, attribute = pairing
          next if errors.any? { |error| error.matches?(cargo: cargo_unit, attr: attribute) }

          errors << Wheelhouse::Validations::Error.new(
            id: cargo_unit.id,
            message: chargeable_error.message,
            attribute: attribute,
            limit: chargeable_error.limit,
            section: 'cargo_item',
            code: 4006
          )
        end
      end

      def validate_aggregate
        keys_for_aggregate_validation.each do |attribute|
          validate_attribute(
            id: 'aggregate',
            attribute: attribute,
            measurement: cargo.send(CARGO_DIMENSION_LOOKUP[attribute]),
            aggregate: true,
            cargo_class: 'lcl'
          )
        end
        return unless cargo.units.all?(&:valid?)

        validate_attribute(
          id: 'aggregate',
          attribute: :chargeable_weight,
          measurement: chargeable_weight(object: cargo),
          aggregate: true,
          cargo_class: 'lcl'
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
        ratio ? (ratio / 1000.0) : DEFAULT_CONVERSION_RATIO
      end

      def validation_attributes
        STANDARD_ATTRIBUTES
      end
    end
  end
end
