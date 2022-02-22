# frozen_string_literal: true

module OfferCalculator
  module Service
    class HubFinder < Base
      def perform
        { origin: "pre", destination: "on" }.reduce({}) do |hubs, (target, carriage)|
          found_hubs = hubs_for_target(target: target, carriage: carriage)
          raise OfferCalculator::Errors::HubNotFound if found_hubs.empty?

          hubs.merge(target => found_hubs)
        end
      end

      private

      def hubs_for_target(target:, carriage:)
        if request.carriage?(carriage: carriage)
          trucking_hubs(carriage: carriage)
        else
          HubsForNexus.new(nexus_id: request.nexus_id(target: target), include_location_groups: include_location_groups?).perform
        end
      end

      def trucking_hubs(carriage:)
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

      def include_location_groups?
        scope[:include_location_groups]
      end

      class HubsForNexus
        def initialize(nexus_id:, include_location_groups:)
          @nexus = Legacy::Nexus.find_by(id: nexus_id)
          @include_location_groups = include_location_groups
        end

        def perform
          if nexus.blank?
            Legacy::Hub.none
          elsif include_location_groups?
            related_hubs.presence || target_hubs
          else
            target_hubs
          end
        end

        private

        attr_reader :nexus, :include_location_groups

        delegate :organization, to: :nexus

        alias include_location_groups? include_location_groups

        def target_hubs
          Legacy::Hub.where(organization: organization, nexus: nexus)
        end

        def related_hubs
          Legacy::Hub.where(organization: organization, nexus_id: location_groups.select(:nexus_id)).distinct
        end

        def location_groups
          @location_groups ||= Pricings::LocationGroup.where(organization: organization, name: nexus_location_groups.select(:name))
        end

        def nexus_location_groups
          @nexus_location_groups ||= Pricings::LocationGroup.where(organization: organization, nexus: nexus)
        end
      end
    end
  end
end
