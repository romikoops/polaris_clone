# frozen_string_literal: true

module Wheelhouse
  class ValidationService
    attr_reader :errors, :request

    def initialize(request:, final: false)
      @request = request
      @routing = request.params.slice(:origin, :destination)
      @errors = []
      @final = final
    end

    delegate :client, :creator, :organization, :cargo_units, :load_type, to: :request

    def validate
      @errors << routing_info_errors if final.present?
      @errors << pricing_validations
      @errors |= cargo_validations
      @errors = errors.compact
      @errors.empty?
    end

    private

    attr_reader :routing, :final

    def scope
      @scope ||= OrganizationManager::ScopeService.new(target: client, organization: organization).fetch
    end

    def groups
      @groups ||= OrganizationManager::GroupsService.new(
        target: client, organization: organization, exclude_default: scope[:dedicated_pricings_only]
      ).fetch
    end

    def cargo_validations
      return [] if cargo_units.empty?

      validation_klass =
        "OfferCalculator::Service::Validations::#{load_type.camelize}ValidationService".safe_constantize
      return [] if validation_klass.nil?

      convert_error_class(
        errors: validation_klass.errors(
          request: request,
          pricings: pricings,
          final: final
        )
      )
    end

    def convert_error_class(errors:)
      errors.map do |error|
        Wheelhouse::Validations::Error.new(
          id: error.id,
          message: error.message,
          attribute: error.attribute,
          section: error.section,
          limit: error.limit,
          code: error.code
        )
      end
    end

    def pricing_validations
      return unless pricings.empty? && (routing.values.all?(&:present?) && !final)

      if scope[:dedicated_pricings_only]
        code = 4009
        message = "No Pricings are available for your groups"
      else
        code = 4008
        message = "No Pricings are available for your route"
      end

      Wheelhouse::Validations::Error.new(
        id: "routing",
        message: message,
        attribute: "routing",
        section: "routing",
        code: code
      )
    end

    def tenant_vehicle_ids
      @tenant_vehicle_ids ||= pricings.select(:tenant_vehicle_id)
    end

    def itinerary_ids
      @itinerary_ids ||= pricings.select(:itinerary_id).distinct
    end

    def pricings
      @pricings ||= Pricings::Pricing.where(
        itinerary: routes, load_type: load_type, group: groups
      ).current
    end

    def routing_info_errors
      return if routing[:origin].present? && routing[:destination].present?

      Wheelhouse::Validations::Error.new(
        id: "routing",
        message: "Origin and destination are required to make a request",
        attribute: "routing",
        section: "routing",
        code: 4016
      )
    end

    def routes
      @routes ||= Wheelhouse::RouteFinderService.routes(
        organization: organization,
        origin: routing[:origin],
        destination: routing[:destination],
        load_type: load_type,
        user: client
      )
    end

    def includes_trucking?
      routing.dig(:origin, :latitude).present? || routing.dig(:destination, :latitude).present?
    end
  end
end
