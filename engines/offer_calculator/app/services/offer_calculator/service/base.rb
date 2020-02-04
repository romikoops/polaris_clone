# frozen_string_literal: true

module OfferCalculator
  module Service
    class Base
      def initialize(shipment: false, sandbox: nil)
        @shipment = shipment
        @scope = Tenants::ScopeService.new(
          target: Tenants::User.find_by(legacy_id: @shipment.user_id),
          tenant: Tenants::Tenant.find_by(legacy_id: @shipment.tenant_id)
        ).fetch
        @pricing_tools = OfferCalculator::PricingTools.new(shipment: @shipment, user: @shipment.user, sandbox: sandbox)
        @sandbox = sandbox
      end

      def quotation_tool?
        @scope['open_quotation_tool'] || @scope['closed_quotation_tool']
      end
    end
  end
end
