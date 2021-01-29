# frozen_string_literal: true

module OfferCalculator
  module Service
    class HubFinder < Base
      def perform
        {origin: "pre", destination: "on"}.reduce({}) do |hubs, (target, carriage)|
          found_hubs = hubs_for_target(target, carriage)
          raise OfferCalculator::Errors::HubNotFound if found_hubs.empty?

          hubs.merge(target => found_hubs)
        end
      end

      private

      def hubs_for_target(target, carriage)
        if request.has_carriage?(carriage: carriage)
          trucking_hubs(carriage: carriage, target: target)
        else
          Legacy::Hub.where(organization: organization,
                            nexus_id: request.nexus_id(target: target))
        end
      end

      def trucking_hubs(carriage:, target:)
        trucking_details = request.trucking_params["#{carriage}_carriage"]
        args = {
          address: carriage == "pre" ? request.pickup_address : request.delivery_address,
          load_type: request.load_type,
          organization_id: organization.id,
          truck_type: trucking_details["truck_type"],
          carriage: carriage,
          cargo_classes: request.cargo_classes,
          groups: groups
        }

        Trucking::Queries::Hubs.new(args).perform
      end

      def groups
        OrganizationManager::GroupsService.new(
          target: client, organization: organization
        ).fetch
      end
    end
  end
end
