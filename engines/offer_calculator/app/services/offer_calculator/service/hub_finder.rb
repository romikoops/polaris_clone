# frozen_string_literal: true

module OfferCalculator
  module Service
    class HubFinder < Base
      def perform
        { origin: 'pre', destination: 'on' }.reduce({}) do |hubs, (target, carriage)|
          found_hubs = hubs_for_target(target, carriage)
          raise OfferCalculator::Errors::HubNotFound if found_hubs.empty?

          hubs.merge(target => found_hubs)
        end
      end

      private

      def hubs_for_target(target, carriage)
        if @shipment.has_carriage?(carriage)
          trucking_hubs(carriage)
        else
          Legacy::Hub.where(organization_id: @shipment.organization_id,
                            nexus_id: @shipment["#{target}_nexus_id"])
        end
      end

      def trucking_hubs(carriage)
        trucking_details = @shipment.trucking["#{carriage}_carriage"]
        args = {
          address: Legacy::Address.find(trucking_details['address_id']),
          load_type: @shipment.load_type,
          organization_id: @shipment.organization_id,
          truck_type: trucking_details['truck_type'],
          carriage: carriage,
          cargo_classes: @shipment.cargo_classes,
          order_by: 'group_id',
          groups: groups
        }
        Trucking::Queries::Hubs.new(args).perform
      end

      def groups
        OrganizationManager::HierarchyService.new(
          target: @shipment.user, organization: @shipment.organization
        ).fetch.select { |hier| hier.is_a?(Groups::Group) }
      end
    end
  end
end
