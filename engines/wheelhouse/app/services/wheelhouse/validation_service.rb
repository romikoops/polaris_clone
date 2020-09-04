# frozen_string_literal: true

module Wheelhouse
  class ValidationService
    attr_reader :errors

    def initialize(user:, organization:, routing:, cargo:, load_type:, final: false)
      @user = user
      @organization = organization
      @routing = routing
      @cargo = cargo
      @load_type = load_type
      @errors = []
      @final = final
      @scope = OrganizationManager::ScopeService.new(target: user, organization: organization).fetch
      @groups = OrganizationManager::HierarchyService.new(
        target: user, organization: organization
      ).fetch.select { |hier|
        hier.is_a?(Groups::Group)
      }
    end

    def validate
      @errors << routing_info_errors if final.present?
      @errors << pricing_validations
      @errors |= cargo_validations
      @errors = errors.compact
      @errors.empty?
    end

    private

    attr_reader :user, :organization, :routing, :cargo, :load_type, :scope, :final, :groups

    def cargo_validations
      return [] if cargo.units.empty?

      validation_klass =
        "OfferCalculator::Service::Validations::#{load_type.camelize}ValidationService".safe_constantize
      return [] if validation_klass.nil?

      convert_error_class(
        errors: validation_klass.errors(
          cargo: cargo,
          modes_of_transport: modes_of_transport,
          itinerary_ids: itinerary_ids,
          tenant_vehicle_ids: tenant_vehicle_ids,
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
        message = 'No Pricings are available for your groups'
      else
        code = 4008
        message = 'No Pricings are available for your route'
      end

      Wheelhouse::Validations::Error.new(
        id: 'routing',
        message: message,
        attribute: 'routing',
        section: 'routing',
        code: code
      )
    end

    def modes_of_transport
      @modes_of_transport ||= routes.where(id: pricings.select(:itinerary_id))
                                    .select(:mode_of_transport)
                                    .distinct
      @modes_of_transport += ['truck_carriage'] if includes_trucking?
      @modes_of_transport
    end

    def tenant_vehicle_ids
      @tenant_vehicle_ids ||= pricings.select(:tenant_vehicle_id)
    end

    def itinerary_ids
      @itinerary_ids ||= pricings.select(:itinerary_id).distinct
    end

    def pricings
      @pricings ||= begin
        pricing_assocation = Pricings::Pricing.where(itinerary: routes, load_type: load_type).current
        pricing_assocation = pricing_assocation.where(group: groups) if scope[:dedicated_pricings_only]
        pricing_assocation
      end
    end

    def routing_info_errors
      return if routing[:origin].present? && routing[:destination].present?

      Wheelhouse::Validations::Error.new(
        id: 'routing',
        message: 'Origin and destination are required to make a request',
        attribute: 'routing',
        section: 'routing',
        code: 4016
      )
    end

    def routes
      @routes ||= Wheelhouse::RouteFinderService.routes(
        organization: organization,
        origin: routing[:origin],
        destination: routing[:destination],
        load_type: load_type,
        user: user
      )
    end

    def includes_trucking?
      routing.dig(:origin, :latitude).present? || routing.dig(:destination, :latitude).present?
    end
  end
end
