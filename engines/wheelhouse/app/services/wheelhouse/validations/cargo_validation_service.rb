# frozen_string_literal: true

module Wheelhouse
  module Validations
    class CargoValidationService
      STANDARD_ATTRIBUTES = %i[
        width
        length
        height
        payload_in_kg
      ].freeze
      AGGREGATE_ATTRIBUTES = %i[
        payload_in_kg
      ].freeze
      CONTAINER_ATTRIBUTES = %i[
        payload_in_kg
      ].freeze
      HUMANIZED_DIMENSION_LOOKUP = {
        width: 'Width',
        length: 'Length',
        height: 'Height',
        payload_in_kg: 'Weight',
        chargeable_weight: 'Chargeable Weight'
      }.freeze
      CARGO_DIMENSION_LOOKUP = {
        width: 'width',
        length: 'length',
        height: 'height',
        payload_in_kg: 'weight'
      }.freeze

      ERROR_CODE_DIMENSION_LOOKUP = {
        width: 4003,
        length: 4004,
        height: 4002,
        payload_in_kg: 4001,
        chargeable_weight: 4005
      }.freeze
      MISSING_DIMENSION_LOOKUP = {
        width: 4012,
        length: 4013,
        height: 4011,
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

      private

      attr_reader :max_dimensions_bundles, :tenant, :cargo, :modes_of_transport,
                  :tenant_vehicle_ids, :errors, :aggregate_errors, :final

      def validate_cargo(cargo_unit:)
        attributes = keys_for_validation(cargo_unit: cargo_unit)
        attributes.each do |attribute|
          validate_attribute(
            id: cargo_unit.id,
            attribute: attribute,
            measurement: cargo_unit.send(CARGO_DIMENSION_LOOKUP[attribute]),
            cargo_class: cargo_unit_class(cargo_unit: cargo_unit)
          )
        end
        if attributes == STANDARD_ATTRIBUTES && load_type == :cargo_item
          validate_attribute(
            id: cargo_unit.id,
            attribute: :chargeable_weight,
            measurement: chargeable_weight(object: cargo_unit),
            cargo_class: 'lcl'
          )
        end

        final_validation(cargo_unit: cargo_unit) if final.present?
      end

      def cargo_unit_class(cargo_unit:)
        return 'lcl' if cargo_unit.cargo_class_00?

        Cargo::Creator::CARGO_CLASS_LEGACY_MAPPER.key(cargo_unit.cargo_class) || 'fcl_20'
      end

      def load_type
        @load_type ||= cargo.units.first.cargo_class_00? ? :cargo_item : :container
      end

      def final_validation(cargo_unit:)
        return if cargo_unit.valid?

        validation_attributes.each do |attribute|
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

        return if cargo_unit.quantity&.positive?

        @errors << Wheelhouse::Validations::Error.new(
          id: cargo_unit.id,
          message: 'Quantity is required.',
          attribute: :quantity,
          limit: nil,
          section: 'cargo_item',
          code: 4017
        )
      end

      def validate_attribute(id:, attribute:, measurement:, cargo_class:, aggregate: false)
        if measurement.value.negative?
          handle_negative_value(id: id, attribute: attribute, measurement: measurement)
          return
        end

        limit = si_attribute_limit(attribute: attribute, aggregate: aggregate, cargo_class: cargo_class)
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

      def si_attribute_limit(attribute:, aggregate:, cargo_class:)
        validation_limit = filtered_max_dimensions(
          aggregate: aggregate,
          attribute: attribute,
          cargo_class: cargo_class
        )

        if %i[chargeable_weight payload_in_kg].include?(attribute)
          Measured::Weight.new(validation_limit, 'kg')
        elsif validation_limit
          Measured::Length.new(validation_limit / 100, 'm')
        end
      end

      def keys_for_validation(cargo_unit:)
        validation_attributes.reject { |key| cargo_unit.send(CARGO_DIMENSION_LOOKUP[key]).value.zero? }
      end

      def filtered_max_dimensions(aggregate:, attribute:, cargo_class:)
        first_filter = max_dimensions_bundles.where(
          aggregate: aggregate,
          cargo_class: cargo_class
        )
        effective_max_dimensions = first_filter.where(
          mode_of_transport: modes_of_transport,
          tenant_vehicle_id: tenant_vehicle_ids
        )

        if effective_max_dimensions.empty?
          effective_max_dimensions = first_filter.where(
            mode_of_transport: modes_of_transport
          )
        end
        if effective_max_dimensions.empty?
          effective_max_dimensions = first_filter.where(
            mode_of_transport: DEFAULT_MOT
          )
        end

        for_comparison = effective_max_dimensions.order("#{attribute} DESC").select(attribute).first
        for_comparison[attribute] || DEFAULT_MAX
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
    end
  end
end
