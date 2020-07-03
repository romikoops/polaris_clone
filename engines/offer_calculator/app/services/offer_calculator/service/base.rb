# frozen_string_literal: true

module OfferCalculator
  module Service
    class Base
      def initialize(shipment: false, sandbox: nil)
        @shipment = shipment
        @organization = Organizations::Organization.find(@shipment.organization_id)
        @creator = @params&.dig(:shipment, :creator)
        @scope = OrganizationManager::ScopeService.new(
          target: Users::User.find_by(id: @shipment.user_id) || @creator,
          organization: organization
        ).fetch
        @sandbox = sandbox
      end

      def quotation_tool?
        @scope['open_quotation_tool'] || @scope['closed_quotation_tool']
      end

      attr_reader :scope, :organization, :wheelhouse
    end
  end
end
