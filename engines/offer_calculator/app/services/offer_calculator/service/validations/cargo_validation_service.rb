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
        TRUCKING_MOT = "truck_carriage"
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

        def main_modes_of_transport
          @main_modes_of_transport ||= [DEFAULT_MOT, pricing_modes_of_transport].flatten
        end

        def pricing_modes_of_transport
          pricings.joins(:itinerary)
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

        def validate_cargo(cargo_unit:)
          cargo_class = cargo_class_from_unit(unit: cargo_unit)
          main_mot_max_dimensions_by_cargo_class = filtered_main_mot_max_dimensions.where(cargo_class: [cargo_class, "general"])
          main_mot_lcl_max_dimensions = filtered_main_mot_max_dimensions.where(cargo_class: "lcl")
          trucking_max_dimensions = filtered_trucking_max_dimensions(aggregate: cargo_unit.id == "aggregate")
          attributes = keys_for_validation(cargo_unit: cargo_unit)

          attributes.each do |attribute|
            validate_attribute(
              main_mot_max_dimensions: main_mot_max_dimensions_by_cargo_class,
              trucking_max_dimensions: trucking_max_dimensions,
              id: cargo_unit.id,
              attribute: attribute,
              measurement: cargo_unit.send(CARGO_DIMENSION_LOOKUP[attribute]),
              cargo: cargo_unit
            )
          end

          if cargo_unit.volume.present?
            validate_attribute(
              main_mot_max_dimensions: main_mot_lcl_max_dimensions,
              trucking_max_dimensions: trucking_max_dimensions,
              id: cargo_unit.id,
              attribute: :volume,
              measurement: cargo_unit.total_volume,
              cargo: cargo_unit
            )
          end

          if attributes == STANDARD_ATTRIBUTES && request.load_type == "cargo_item"
            validate_attribute(
              main_mot_max_dimensions: main_mot_lcl_max_dimensions,
              trucking_max_dimensions: trucking_max_dimensions,
              id: cargo_unit.id,
              attribute: :chargeable_weight,
              measurement: cargo_unit.chargeable_weight,
              cargo: cargo_unit
            )
          end

          final_validation(cargo_unit: cargo_unit) if final.present?
        end

        def cargo_class_from_unit(unit:)
          (unit.cargo_class.include?("lcl") ? "lcl" : unit.cargo_class)
        end

        def filtered_main_mot_max_dimensions(aggregate: false)
          filtered_max_dimensions(aggregate: aggregate, modes_of_transport: main_modes_of_transport)
        end

        def filtered_max_dimensions(aggregate:, modes_of_transport:)
          query = max_dimensions_bundles.where(aggregate: aggregate, mode_of_transport: modes_of_transport)

          if query.blank?
            query
          else
            query = query.where(itinerary_id: itinerary_ids).presence || query
            query = query.where(tenant_vehicle_id: tenant_vehicle_ids).presence || query
            query.where(carrier_id: carrier_ids).presence || query
          end
        end

        def keys_for_validation(cargo_unit:)
          validation_attributes.reject { |key| cargo_unit.send(CARGO_DIMENSION_LOOKUP[key]).value.zero? }
        end

        def validate_attribute(main_mot_max_dimensions:, trucking_max_dimensions:, id:, attribute:, measurement:, cargo:)
          return handle_negative_value(id: id, attribute: attribute) if measurement.value.negative?

          limit = si_attribute_limit(
            main_mot_max_dimensions: main_mot_max_dimensions,
            trucking_max_dimensions: trucking_max_dimensions,
            attribute: attribute
          )
          return if limit >= measurement

          build_error(attribute: attribute, limit: limit, id: id, cargo: cargo, measurement: measurement)
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

        def si_attribute_limit(main_mot_max_dimensions:, trucking_max_dimensions:, attribute:)
          main_mot_limit = main_mot_max_dimensions.pluck(attribute).min
          trucking_limit = trucking_max_dimensions.pluck(attribute).min
          effective_limit = [main_mot_limit, trucking_limit].compact.min || DEFAULT_MAX

          if %i[chargeable_weight payload_in_kg].include?(attribute)
            Measured::Weight.new(effective_limit, "kg")
          elsif attribute == :volume
            Measured::Volume.new(effective_limit, "m3")
          elsif effective_limit
            Measured::Length.new(effective_limit / 100, "m")
          end
        end

        def filtered_trucking_max_dimensions(aggregate: false)
          if trucking_involved?
            filtered_max_dimensions(aggregate: aggregate, modes_of_transport: [TRUCKING_MOT])
          else
            ::Legacy::MaxDimensionsBundle.none
          end
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
      end
    end
  end
end
