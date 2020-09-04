# frozen_string_literal: true

require_dependency 'api/api_controller'

module Api
  module V1
    class TruckingAvailabilitiesController < ApiController
      def index
        render json: availability
      end

      private

      def availability
        Api::Routing::Trucking::AvailabilityService.availability(
          organization: current_organization,
          load_type: trucking_params[:load_type],
          coordinates: coordinates,
          user: client,
          target: target_param
        )
      end

      def trucking_params
        params.permit(:lat, :lng, :id, :load_type, :client)
      end

      def client
        client_id = trucking_params[:client]
        Organizations::User.find(client_id) if client_id
      end

      def coordinates
        trucking_params.slice(:lat, :lng)
      end

      def target_param
        params.require(:target)&.to_sym
      end
    end
  end
end
