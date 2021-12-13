# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V1
    class TruckingCounterpartsController < ApiController
      include UsersUserAccess
      def index
        render json: counterpart
      end

      private

      def counterpart
        Api::Routing::Trucking::CounterpartService.counterpart_availabilities(
          organization: current_organization,
          user: client,
          target: target_param,
          trucking_details: trucking_details
        )
      end

      def trucking_details
        @trucking_details = Api::Routing::Trucking::DetailsService.new(coordinates: coordinates,
                                                                       nexus_id: trucking_params[:id],
                                                                       load_type: trucking_params[:load_type])
      end

      def trucking_params
        params.permit(:lat, :lng, :id, :load_type, :client)
      end

      def client
        client_id = trucking_params[:client]
        Users::Client.find(client_id) if client_id
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
