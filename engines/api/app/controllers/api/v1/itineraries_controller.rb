# frozen_string_literal: true

require_dependency 'api/api_controller'

module Api
  module V1
    class ItinerariesController < ApiController
      skip_before_action :doorkeeper_authorize!, only: :ports

      def index
        tenant = current_user.tenant.legacy
        itineraries = Legacy::Itinerary.where(tenant_id: tenant.id)
        render json: itineraries
      end

      def ports
        tenant = Tenants::Tenant.find(params[:tenant_uuid])
        itineraries = Legacy::Itinerary.where(sandbox: @sandbox, tenant_id: tenant.legacy_id, mode_of_transport: 'ocean')

        stops_by_itinerary = Legacy::Stop.includes(:hub)
                                 .where(itinerary_id: itineraries.ids)
                                 .order(:index)
                                 .group_by(&:itinerary_id)

        render json: itineraries, each_serializer: ItineraryPortSerializer, scope: { stops_by_itinerary: stops_by_itinerary }
      end
    end
  end
end
