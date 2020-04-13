# frozen_string_literal: true

module Wheelhouse
  module Validations
    class CargoValidationService
      STANDARD_ATTRIBUTES = %i[
        dimension_x
        dimension_y
        dimension_z
        payload_in_kg
      ].freeze
      AGGREGATE_ATTRIBUTES = %i[
        payload_in_kg
      ].freeze
      HUMANIZED_DIMENSION_LOOKUP = {
        dimension_x: 'Width',
        dimension_y: 'Length',
        dimension_z: 'Height',
        payload_in_kg: 'Weight',
        chargeable_weight: 'Chargeable Weight'
      }.freeze
      CARGO_DIMENSION_LOOKUP = {
        dimension_x: 'width',
        dimension_y: 'length',
        dimension_z: 'height',
        payload_in_kg: 'weight'
      }.freeze

      ERROR_CODE_DIMENSION_LOOKUP = {
        dimension_x: 4003,
        dimension_y: 4004,
        dimension_z: 4002,
        payload_in_kg: 4001,
        chargeable_weight: 4005
      }.freeze
      MISSING_DIMENSION_LOOKUP = {
        dimension_x: 4012,
        dimension_y: 4013,
        dimension_z: 4011,
        payload_in_kg: 4010
      }.freeze

      DEFAULT_MAX = Float::INFINITY
      DEFAULT_MOT = 'general'
      DEFAULT_CONVERSION_RATIO = 1_000

      def self.errors(tenant:, cargo:, modes_of_transport:, tenant_vehicle_ids:, final: false)
        new(
          tenant: tenant,
          cargo: cargo,
          modes_of_transport: modes_of_transport,
          tenant_vehicle_ids: tenant_vehicle_ids,
          final: final
        ).perform
      end

      def initialize(tenant:, cargo:, modes_of_transport: [], tenant_vehicle_ids:, final: false)
        @tenant = tenant
        @cargo = cargo
        @max_dimensions_bundles = ::Legacy::MaxDimensionsBundle.where(tenant_id: @tenant.legacy_id)
        @modes_of_transport = modes_of_transport
        @tenant_vehicle_ids = tenant_vehicle_ids
        @aggregate_errors = []
        @errors = []
        @final = final
      end

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

      attr_reader :max_dimensions_bundles, :tenant, :cargo, :modes_of_transport,
                  :tenant_vehicle_ids, :errors, :aggregate_errors, :final

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
            aggregate: true
          )
        end
        return unless cargo.units.all?(&:valid?)

        validate_attribute(
          id: 'aggregate',
          attribute: :chargeable_weight,
          measurement: chargeable_weight(object: cargo),
          aggregate: true
        )
      end

      def validate_cargo(cargo_unit:)
        attributes = keys_for_validation(cargo_unit: cargo_unit)
        attributes.each do |attribute|
          validate_attribute(
            id: cargo_unit.id,
            attribute: attribute,
            measurement: cargo_unit.send(CARGO_DIMENSION_LOOKUP[attribute])
          )
        end
        if attributes == STANDARD_ATTRIBUTES
          validate_attribute(
            id: cargo_unit.id,
            attribute: :chargeable_weight,
            measurement: chargeable_weight(object: cargo_unit)
          )
        end

        final_validation(cargo_unit: cargo_unit) if final.present?
      end

      def keys_for_validation(cargo_unit:)
        STANDARD_ATTRIBUTES.reject { |key| cargo_unit.send(CARGO_DIMENSION_LOOKUP[key]).value.zero? }
      end

      def keys_for_aggregate_validation
        AGGREGATE_ATTRIBUTES.reject do |key|
          cargo.units.all? { |cargo| cargo.send(CARGO_DIMENSION_LOOKUP[key]).value.zero? }
        end
      end

      def validate_attribute(id:, attribute:, measurement:, aggregate: false)
        if measurement.value.negative?
          handle_negative_value(id: id, attribute: attribute, measurement: measurement)
          return
        end

        limit = si_attribute_limit(attribute: attribute, aggregate: aggregate)
        return if limit >= measurement

        message = "#{HUMANIZED_DIMENSION_LOOKUP[attribute]} exceeds the limit of #{limit}"
        message = 'Aggregate ' + message if id == 'aggregate'
        error = Wheelhouse::Validations::Error.new(
          id: id,
          message: message,
          attribute: attribute,
          limit: limit,
          section: 'cargo_item',
          code: ERROR_CODE_DIMENSION_LOOKUP[attribute]
        )
        if id == 'aggregate'
          aggregate_errors << error
        else
          errors << error
        end
      end

      def handle_negative_value(id:, attribute:, measurement:)
        @errors << Wheelhouse::Validations::Error.new(
          id: id,
          message: "#{HUMANIZED_DIMENSION_LOOKUP[attribute]} must be positive.",
          attribute: attribute,
          limit: 0,
          section: 'cargo_item',
          code: 4015
        )
      end

      def final_validation(cargo_unit:)
        return if cargo_unit.valid?

        STANDARD_ATTRIBUTES.each do |attribute|
          next if cargo_unit.send(CARGO_DIMENSION_LOOKUP[attribute]).value.positive?

          @errors << Wheelhouse::Validations::Error.new(
            id: cargo_unit.id,
            message: "#{HUMANIZED_DIMENSION_LOOKUP[attribute]} is required.",
            attribute: attribute,
            limit: nil,
            section: 'cargo_item',
            code: MISSING_DIMENSION_LOOKUP[attribute]
          )
        end
      end

      def si_attribute_limit(attribute:, aggregate:)
        validation_limit = filtered_max_dimensions(aggregate: aggregate, attribute: attribute)
        if %i[chargeable_weight payload_in_kg].include?(attribute)
          Measured::Weight.new(validation_limit, 'kg')
        elsif validation_limit
          Measured::Length.new(validation_limit / 100, 'm')
        end
      end

      def filtered_max_dimensions(aggregate:, attribute:)
        effective_max_dimensions = max_dimensions_bundles.where(
          aggregate: aggregate,
          mode_of_transport: modes_of_transport,
          tenant_vehicle_id: tenant_vehicle_ids
        )

        if effective_max_dimensions.empty?
          effective_max_dimensions = max_dimensions_bundles.where(
            aggregate: aggregate,
            mode_of_transport: modes_of_transport
          )
        end
        if effective_max_dimensions.empty?
          effective_max_dimensions = max_dimensions_bundles.where(
            aggregate: aggregate,
            mode_of_transport: DEFAULT_MOT
          )
        end
        for_comparison = effective_max_dimensions.order("#{attribute} DESC").select(attribute).first
        for_comparison[attribute] || DEFAULT_MAX
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
    end
  end
end
