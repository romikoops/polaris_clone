# frozen_string_literal: true

module OfferCalculatorService
  class Base
    def initialize(shipment: false, sandbox: nil)
      @shipment = shipment
      @scope = Tenants::ScopeService.new(
        target: Tenants::User.find_by(legacy_id: @shipment.user_id),
        tenant: Tenants::Tenant.find_by(legacy_id: @shipment.tenant_id)
      ).fetch

      @pricing_tools = PricingTools.new(shipment: @shipment, user: @shipment.user, sandbox: sandbox)
      @sandbox = sandbox
    end
  end
end
