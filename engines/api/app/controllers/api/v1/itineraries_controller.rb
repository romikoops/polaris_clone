# frozen_string_literal: true

require_dependency 'api/api_controller'

module Api
  module V1
    class ItinerariesController < ApiController
      ORIGIN_INDEX = 0
      DESTINATION_INDEX = 1

      skip_before_action :doorkeeper_authorize!, only: :ports, raise: false

      def index
        itineraries = Legacy::Itinerary.where(organization: current_organization)
        render json: ItinerarySerializer.new(itineraries, params: { includes: ['stops'] })
      end
    end
  end
end
