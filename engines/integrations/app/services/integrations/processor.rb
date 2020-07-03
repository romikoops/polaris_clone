# frozen_string_literal: true

module Integrations
  class Processor
    def self.process(shipment_request_id:, organization_id:)
      return unless chainio_integration_enabled?(organization_id: organization_id)

      ChainIo::Processor.process(shipment_request_id: shipment_request_id, organization_id: organization_id)
    end

    def self.chainio_integration_enabled?(organization_id:)
      OrganizationManager::ScopeService.new(
        target: ::Organizations::Organization.find(organization_id)
      ).fetch(:integrations, :chainio, :api_key).present?
    end
  end
end
