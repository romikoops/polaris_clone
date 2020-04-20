# frozen_string_literal: true

module Wheelhouse
  class ValidationService
    attr_reader :errors

    def initialize(user:, routing:, cargo:, load_type:, final: false)
      @user = user
      @tenant = user.tenant
      @routing = routing
      @cargo = cargo
      @load_type = load_type
      @errors = []
      @final = final
      @scope = Tenants::ScopeService.new(target: user, tenant: @tenant).fetch
    end

    def validate
      @errors << routing_info_errors if final.present?
      @errors << pricing_validations
      @errors |= cargo_validations
      @errors = errors.compact
      @errors.empty?
    end

    private

    attr_reader :user, :tenant, :routing, :cargo, :load_type, :scope, :final

    def cargo_validations
      return [] if cargo.units.empty?

      validation_klass = "Wheelhouse::Validations::#{load_type.camelize}ValidationService".safe_constantize
      return [] if validation_klass.nil?

      validation_klass.errors(
        cargo: cargo,
        tenant: tenant,
        modes_of_transport: modes_of_transport,
        tenant_vehicle_ids: tenant_vehicle_ids,
        final: final
      )
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
      @modes_of_transport ||= routes.select(:mode_of_transport)
    end

    def tenant_vehicle_ids
      @tenant_vehicle_ids ||= pricings.select(:tenant_vehicle_id)
    end

    def pricings
      @pricings ||= begin
        pricing_assocation = Pricings::Pricing.where(itinerary: routes)
        pricing_assocation = pricing_assocation.where(group: user.all_groups) if scope[:dedicated_pricings_only]
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
        origin: routing[:origin],
        destination: routing[:destination],
        load_type: load_type,
        user: user
      )
    end
  end
end
