# frozen_string_literal: true

module Integrations
  class Processor
    def self.process(shipment_request_id:, tenant_id:)
      if chainio_integration_enabled?(tenant_id: tenant_id)
        ChainIo::Processor.process(shipment_request_id: shipment_request_id, tenant_id: tenant_id)
      end
    end

    def self.chainio_integration_enabled?(tenant_id:)
      Tenants::ScopeService.new(
        tenant: Tenants::Tenant.find(tenant_id)
      ).fetch(:integrations, :chainio, :api_key).present?
    end
  end
end
