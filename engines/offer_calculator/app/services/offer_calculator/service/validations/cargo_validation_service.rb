# frozen_string_literal: true

module OfferCalculator
  module Service
    module Validations
      class CargoValidationService
        STANDARD_ATTRIBUTES = %i[
          width
          length
          height
          payload_in_kg
        ].freeze
        VOLUME_DIMENSIONS = %i[
          width
          length
          height
        ].freeze
        AGGREGATE_ATTRIBUTES = %i[
          payload_in_kg
          volume
        ].freeze
        CONTAINER_ATTRIBUTES = %i[
          payload_in_kg
        ].freeze
        HUMANIZED_DIMENSION_LOOKUP = {
          width: "Width",
          length: "Length",
          height: "Height",
          payload_in_kg: "Weight",
          chargeable_weight: "Chargeable Weight",
          volume: "Volume"
        }.freeze
        CARGO_DIMENSION_LOOKUP = {
          width: "width",
          length: "length",
          height: "height",
          payload_in_kg: "weight",
          volume: "volume"
        }.freeze

        ERROR_CODE_DIMENSION_LOOKUP = {
          width: 4003,
          length: 4004,
          height: 4002,
          payload_in_kg: 4001,
          chargeable_weight: 4005,
          volume: 4018
        }.freeze

        AGGREGATE_ERROR_CODE_DIMENSION_LOOKUP = {
          chargeable_weight: 4006,
          volume: 4019
        }.freeze

        MISSING_DIMENSION_LOOKUP = {
          width: 4012,
          length: 4013,
          height: 4011,
          payload_in_kg: 4010
        }.freeze

        DEFAULT_MAX = Float::INFINITY
        DEFAULT_MOT = "general"
        DEFAULT_CONVERSION_RATIO = 1_000

        def self.errors(request:, pricings:, final: false)
          new(
            request: request,
            pricings: pricings,
            final: final
          ).perform
        end

        def initialize(request:, pricings:, final: false)
          @request = request
          @pricings = pricings
          @aggregate_errors = []
          @errors = []
          @final = final
        end

        private

        attr_reader :errors, :aggregate_errors, :final, :pricings, :request

        delegate :organization, :load_type, :client, :creator, to: :request

        def modes_of_transport
          @modes_of_transport ||= begin
            if trucking_involved?
              pricing_modes_of_transport + ["truck_carriage"]
            else
              pricing_modes_of_transport
            end
          end
        end

        def pricing_modes_of_transport
          @pricing_modes_of_transport ||= pricings.joins(:itinerary)
            .select("itineraries.mode_of_transport")
            .distinct
            .pluck(:mode_of_transport)
        end

        def trucking_involved?
          request.pre_carriage? || request.on_carriage?
        end

        def itinerary_ids
          @itinerary_ids ||= pricings.select(:itinerary_id).distinct
        end

        def tenant_vehicle_ids
          @tenant_vehicle_ids ||= pricings.select(:tenant_vehicle_id).distinct
        end

        def carrier_ids
          @carrier_ids ||= Legacy::TenantVehicle.where(id: @tenant_vehicle_ids).pluck(:carrier_id)
        end

        def cargo_units
          measured_request.validation_targets
        end

        def largest_ratio_rate
          pricing = pricings_for_rate.order(wm_rate: :desc).first

          Pricings::ManipulatorResult.new(
            original: pricing,
            result: pricing.as_json,
            breakdowns: [],
            flat_margins: {}
          )
        end

        def pricings_for_rate
          return pricings if pricings.present?

          pricings_for_load_type = Pricings::Pricing.where(organization: organization, load_type: load_type)
          pricings_for_load_type = Pricings::Pricing.where(organization: organization) if pricings_for_load_type.empty?
          pricings_for_load_type.order(wm_rate: :desc).limit(1)
        end

        def measured_request
          OfferCalculator::Service::Measurements::Request.new(
            request: request, scope: scope, object: largest_ratio_rate
          )
        end

        def scope
          @scope ||= OrganizationManager::ScopeService.new(target: client, organization: organization).fetch
        end

        def max_dimensions_bundles
          @max_dimensions_bundles ||= ::Legacy::MaxDimensionsBundle.where(organization_id: organization.id)
        end

        def cargo_class_from_unit(unit:)
          unit.cargo_class.include?("lcl") ? "lcl" : unit.cargo_class
        end

        def validate_cargo(cargo_unit:)
          cargo_class = cargo_class_from_unit(unit: cargo_unit)
          max_dimensions_by_cargo_class = filtered_max_dimensions.where(cargo_class: cargo_class)
          lcl_max_dimensions = filtered_max_dimensions.where(cargo_class: "lcl")
          attributes = keys_for_validation(cargo_unit: cargo_unit)
          attributes.each do |attribute|
            validate_attribute(
              max_dimensions: max_dimensions_by_cargo_class,
              id: cargo_unit.id,
              attribute: attribute,
              measurement: cargo_unit.send(CARGO_DIMENSION_LOOKUP[attribute]),
              cargo: cargo_unit
            )
          end

          validate_volume(lcl_max_dimensions: lcl_max_dimensions, cargo_unit: cargo_unit)

          if attributes == STANDARD_ATTRIBUTES && request.load_type == "cargo_item"
            validate_attribute(
              max_dimensions: lcl_max_dimensions,
              id: cargo_unit.id,
              attribute: :chargeable_weight,
              measurement: cargo_unit.chargeable_weight,
              cargo: cargo_unit
            )
          end

          final_validation(cargo_unit: cargo_unit) if final.present?
        end

        def validate_volume(lcl_max_dimensions:, cargo_unit:)
          return if cargo_unit.volume.blank?

          validate_attribute(
            max_dimensions: lcl_max_dimensions,
            id: cargo_unit.id,
            attribute: :volume,
            measurement: cargo_unit.total_volume,
            cargo: cargo_unit
          )
        end

        def final_validation(cargo_unit:)
          validation_attributes.each do |attribute|
            next if cargo_unit.send(CARGO_DIMENSION_LOOKUP[attribute]).value.positive?

            @errors << OfferCalculator::Service::Validations::Error.new(
              id: cargo_unit.id,
              message: "#{HUMANIZED_DIMENSION_LOOKUP[attribute]} is required.",
              attribute: attribute,
              limit: nil,
              section: "cargo_item",
              code: MISSING_DIMENSION_LOOKUP[attribute]
            )
          end

          return if cargo_unit.quantity&.positive?

          @errors << OfferCalculator::Service::Validations::Error.new(
            id: cargo_unit.id,
            message: "Quantity is required.",
            attribute: :quantity,
            limit: nil,
            section: "cargo_item",
            code: 4017
          )
        end

        def validate_attribute(max_dimensions:, id:, attribute:, measurement:, cargo:)
          if measurement.value.negative?
            handle_negative_value(id: id, attribute: attribute)
            return
          end
          limit = si_attribute_limit(max_dimensions: max_dimensions, attribute: attribute)
          return if limit >= measurement

          build_error(attribute: attribute, limit: limit, id: id, cargo: cargo, measurement: measurement)
        end

        def build_error(attribute:, limit:, id:, cargo:, measurement:)
          message = "#{HUMANIZED_DIMENSION_LOOKUP[attribute]} exceeds the limit of #{limit}"
          message = "Aggregate #{message}" if id == "aggregate"
          code = ERROR_CODE_DIMENSION_LOOKUP[attribute]
          code = AGGREGATE_ERROR_CODE_DIMENSION_LOOKUP[attribute] if id == "aggregate"

          error = OfferCalculator::Service::Validations::Error.new(
            id: id,
            message: message,
            attribute: attribute,
            limit: dynamic_limit(limit: limit, attribute: attribute),
            section: "cargo_item",
            code: code,
            value: measurement.format
          )

          return if errors.any? do |match_error|
            match_error.matches?(cargo: cargo, attr: attribute, aggregate: id == "aggregate")
          end

          if id == "aggregate"
            aggregate_errors << error
          else
            errors << error
          end
        end

        def dynamic_limit(limit:, attribute:)
          return "Chargeable Weight Exceeded" if attribute == :chargeable_weight

          limit
        end

        def trucking_limit(attribute:)
          return Float::INFINITY unless modes_of_transport.include? "truck_carriage"
          return Float::INFINITY if trucking_max_dimensions.empty?

          trucking_max_dimensions.select(attribute).max.send(attribute)
        end

        def si_attribute_limit(max_dimensions:, attribute:)
          main_mot_limit = max_dimensions.select(attribute).max&.send(attribute)
          trucking_limit = trucking_limit(attribute: attribute)

          for_comparison = [main_mot_limit, trucking_limit].compact.min
          validation_limit = for_comparison || DEFAULT_MAX

          if %i[chargeable_weight payload_in_kg].include?(attribute)
            Measured::Weight.new(validation_limit, "kg")
          elsif attribute == :volume
            Measured::Volume.new(validation_limit, "m3")
          elsif validation_limit
            Measured::Length.new(validation_limit / 100, "m")
          end
        end

        def keys_for_validation(cargo_unit:)
          validation_attributes.reject { |key| cargo_unit.send(CARGO_DIMENSION_LOOKUP[key]).value.zero? }
        end

        def filtered_max_dimensions(aggregate: false)
          first_filter = aggregate_and_route_filter(aggregate: aggregate)

          effective_max_dimensions = first_filter.where(
            mode_of_transport: modes_of_transport,
            tenant_vehicle_id: tenant_vehicle_ids
          )

          if effective_max_dimensions.empty?
            effective_max_dimensions = first_filter.where(
              mode_of_transport: modes_of_transport,
              carrier_id: carrier_ids
            )
          end

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

          effective_max_dimensions
        end

        def aggregate_and_route_filter(aggregate: false)
          query = max_dimensions_bundles.where(
            aggregate: aggregate,
            itinerary_id: itinerary_ids
          )

          return query if query.present?

          max_dimensions_bundles.where(
            aggregate: aggregate
          )
        end

        def trucking_max_dimensions
          @trucking_max_dimensions ||=
            filtered_max_dimensions.where(mode_of_transport: "truck_carriage")
        end

        def handle_negative_value(id:, attribute:)
          @errors << OfferCalculator::Service::Validations::Error.new(
            id: id,
            message: "#{HUMANIZED_DIMENSION_LOOKUP[attribute]} must be positive.",
            attribute: attribute,
            limit: 0,
            section: "cargo_item",
            code: 4015
          )
        end
      end
    end
  end
end
