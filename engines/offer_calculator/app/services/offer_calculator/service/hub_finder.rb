# frozen_string_literal: true

module OfferCalculator
  module Service
    class HubFinder < Base
      def perform
        { origin: 'pre', destination: 'on' }.reduce({}) do |hubs, (target, carriage)|
          hubs.merge(target => hubs_for_target(target, carriage))
        end
      end

      private

      def hubs_for_target(target, carriage)
        if @shipment.has_carriage?(carriage)
          Legacy::Hub.where(id: trucking_hub_ids(carriage))
        else
          @shipment.tenant.hubs.where(sandbox: @sandbox, nexus_id: @shipment["#{target}_nexus_id"])
        end
      end

      def trucking_hub_ids(carriage)
        trucking_details = @shipment.trucking["#{carriage}_carriage"]
        base_pricing_enabled = Tenants::ScopeService.new(
          target: ::Tenants::User.find_by(legacy_id: @shipment.user)
        ).fetch(:base_pricing)
        args = {
          address: Legacy::Address.find(trucking_details['address_id']),
          load_type: @shipment.load_type,
          tenant_id: @shipment.tenant_id,
          truck_type: trucking_details['truck_type'],
          carriage: carriage,
          cargo_classes: @shipment.cargo_classes,
          sandbox: @sandbox,
          order_by: base_pricing_enabled ? 'group_id' : 'user_id'
        }
        results = Trucking::Queries::Availability.new(args).perform | Trucking::Queries::Distance.new(args).perform
        results.map(&:hub_id)
      end
    end
  end
end
