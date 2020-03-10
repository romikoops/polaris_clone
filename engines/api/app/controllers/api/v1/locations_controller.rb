# frozen_string_literal: true

require_dependency 'api/application_controller'

module Api
  module V1
    class LocationsController < ApiController
      ORIGIN_INDEX = 0
      DESTINATION_INDEX = 1

      def origins
        origin_nexuses = nexuses(direction: :origin_destination)

        render json: NexusDecorator.decorate_collection(origin_nexuses), each_serializer: NexusSerializer
      end

      def destinations
        destination_nexuses = nexuses(direction: :destination_origin)

        render json: NexusDecorator.decorate_collection(destination_nexuses), each_serializer: NexusSerializer
      end

      private

      def nexuses(direction:)
        if direction == :origin_destination
          index = ORIGIN_INDEX
          counterpart_index = DESTINATION_INDEX
          carriage = 'on'
        else
          index = DESTINATION_INDEX
          counterpart_index = ORIGIN_INDEX
          carriage = 'pre'
        end

        itineraries = location_itineraries(itineraries: tenant_itineraries,
                                           index: counterpart_index, carriage: carriage)
        itineraries_nexuses(itineraries, index)
      end

      def itineraries_nexuses(itineraries, index)
        hubs = Legacy::Hub.joins(:stops)
                          .where(stops: { itinerary: itineraries, index: index })
                          .order(:name)
        hubs_nexuses(hubs)
      end

      def nexus_hubs(nexus_id)
        Legacy::Hub.where(nexus_id: nexus_id).ids
      end

      def hubs_nexuses(hubs)
        nexuses = Legacy::Nexus.where(id: hubs.pluck(:nexus_id))
        nexuses = nexuses.name_search(location_params[:q]) if location_params[:q].present?
        nexuses
      end

      def location_params
        params.permit(:q, :id, :lat, :lng)
      end

      def tenant_itineraries
        Legacy::Itinerary.joins(stops: :hub)
                         .where(sandbox: @sandbox,
                                tenant_id: current_tenant.legacy_id)
      end

      def location_itineraries(itineraries:, index:, carriage:)
        return itineraries unless location?

        if params[:id].present?
          itineraries = itineraries.where(stops: { index: index, hub_id: nexus_hubs(params[:id]) })
        end
        if params[:lat].present? && params[:lng].present?
          hubs = carriage_hubs_for(lat: params[:lat], lng: params[:lng], carriage: carriage)
          itineraries = itineraries.where(stops: { index: index, hub_id: hubs })
        end
        itineraries
      end

      def carriage_hubs_for(lat:, lng:, carriage:)
        trucking_params = trucking_args(lat: lat, lng: lng, carriage: carriage)

        trucking_pricings ||= begin
          area_results = ::Trucking::Queries::Availability.new(trucking_params).perform
          distance_results = ::Trucking::Queries::Distance.new(trucking_params).perform
          area_results | distance_results
        end

        trucking_pricings.pluck(:hub_id)
      end

      def trucking_args(lat:, lng:, carriage:)
        {
          tenant_id: current_tenant.legacy_id,
          address: address(lat: lat, lng: lng),
          carriage: carriage,
          klass: Trucking::Trucking,
          sandbox: @sandbox,
          order_by: base_pricing_enabled ? 'group_id' : 'user_id'
        }
      end

      def address(lat:, lng:)
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

      def base_pricing_enabled
        Tenants::ScopeService.new(
          target: current_user,
          tenant: current_tenant
        ).fetch(:base_pricing)
      end

      def location?
        params[:id] || (params[:lat] && params[:lat])
      end
    end
  end
end
