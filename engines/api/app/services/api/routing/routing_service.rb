# frozen_string_literal: true

module Api
  module Routing
    class RoutingService
      ORIGIN_INDEX = 0
      DESTINATION_INDEX = 1

      def self.nexuses(tenant:, load_type:, target:, coordinates: nil, nexus_id: nil, query: nil)
        new(tenant: tenant,
            load_type: load_type,
            target: target,
            coordinates: coordinates,
            nexus_id: nexus_id,
            query: query).perform
      end

      def initialize(tenant:, load_type:, target:, coordinates: nil, nexus_id: nil, query: nil)
        @legacy_tenant_id = tenant.legacy_id
        @query = query
        @load_type = load_type
        @target = target
        @lat = coordinates&.dig(:lat)
        @lng = coordinates&.dig(:lng)
        @nexus_id = nexus_id
      end

      def perform
        itineraries_nexuses(target_index: index).reorder('name')
      end

      private

      attr_reader :legacy_tenant_id, :lat, :lng, :nexus_id, :load_type, :target, :query

      def itineraries_from_lat_lng
        return tenant_itineraries.where(origin_hub: carriage_hubs) if index == DESTINATION_INDEX

        tenant_itineraries.where(destination_hub: carriage_hubs)
      end

      def itineraries_from_nexus_id
        return tenant_itineraries.where(origin_hub: nexus_hubs(nexus_id: nexus_id)) if index == DESTINATION_INDEX

        tenant_itineraries.where(destination_hub: nexus_hubs(nexus_id: nexus_id))
      end

      def index
        target == :origin_destination ? ORIGIN_INDEX : DESTINATION_INDEX
      end

      def counterpart_index
        target == :origin_destination ? DESTINATION_INDEX : ORIGIN_INDEX
      end

      def carriage
        target == :origin_destination ? 'on' : 'pre'
      end

      def tenant_itineraries
        @tenant_itineraries ||= Legacy::Itinerary.where(tenant_id: legacy_tenant_id)
      end

      def itineraries
        tenant_itineraries
      end

      def itineraries_hubs(target_index:)
        return Legacy::Hub.where(id: itineraries.select(:origin_hub_id)) if target_index == ORIGIN_INDEX

        Legacy::Hub.where(id: itineraries.select(:destination_hub_id))
      end

      def itineraries_nexuses(target_index:)
        nexuses = Legacy::Nexus.joins(:hubs)
                               .where(hubs: itineraries_hubs(target_index: target_index))

        nexuses = nexuses.name_search(query) if query.present?
        nexuses.reorder('').distinct
      end

      def nexus_hubs(nexus_id:)
        Legacy::Hub.where(tenant_id: legacy_tenant_id, nexus_id: nexus_id)
      end

      def carriage_hubs
        ::Trucking::Queries::Hubs.new(carriage_arguments).perform
      end

      def carriage_arguments
        {
          tenant_id: legacy_tenant_id,
          address: address,
          carriage: carriage,
          order_by: 'group_id',
          load_type: load_type
        }
      end

      def address
        address = Geocoder.search([lat.to_f, lng.to_f]).first
        return unless address

        OpenStruct.new(
          latitude: lat.to_f,
          longitude: lng.to_f,
          get_zip_code: address.postal_code,
          city_name: address.city,
          country: OpenStruct.new(code: address.country_code)
        )
      end
    end
  end
end
