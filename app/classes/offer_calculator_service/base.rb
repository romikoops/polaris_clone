# frozen_string_literal: true

module OfferCalculatorService
  class Base
    def initialize(shipment: false, sandbox: nil)
      @shipment = shipment
      tenants_tenant = Tenants::Tenant.find_by(legacy_id: shipment.tenant_id)
      @scope    = ::Tenants::ScopeService.new(target: @shipment.user, tenant: tenants_tenant).fetch
      @pricing_tools = PricingTools.new(shipment: @shipment, user: @shipment.user, sandbox: sandbox)
      @sandbox = sandbox
    end
  end
end
