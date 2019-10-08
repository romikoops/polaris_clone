# frozen_string_literal: true

require_dependency 'api/api_controller'

module Api
  module V1
    class ItinerariesController < ApiController
      def index
        tenant = current_user.tenant.legacy
        itineraries = Legacy::Itinerary.where(tenant_id: tenant.id)
        render json: itineraries
      end
    end
  end
end
