# frozen_string_literal: true

require_dependency 'api/api_controller'

module Api
  module V1
    class TruckingCapabilitiesController < ApiController
      def index
        render json: { data: capability }
      end

      private

      def capability
        Api::Routing::Trucking::CapabilityService.capability(
          tenant: current_tenant,
          load_type: trucking_params[:load_type]
        )
      end

      def trucking_params
        params.permit(:load_type)
      end
    end
  end
end
