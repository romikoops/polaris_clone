# frozen_string_literal: true

require_dependency 'api/api_controller'

module Api
  module V1
    class TruckingCounterpartsController < ApiController
      def index
        render json: counterpart
      end

      private

      def counterpart
        Api::Routing::Trucking::CounterpartService.counterpart_availabilities(
          organization: current_organization,
          load_type: trucking_params[:load_type],
          coordinates: coordinates,
          nexus_id: trucking_params[:id],
          target: target_param
        )
      end

      def trucking_params
        params.permit(:lat, :lng, :id, :load_type)
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
