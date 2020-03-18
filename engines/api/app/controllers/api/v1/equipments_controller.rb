# frozen_string_literal: true

module Api
  module V1
    class EquipmentsController < ApiController
      def index
        equipment_classes = Api::EquipmentService.new(
          user: current_user,
          origin_nexus_id: fcl_params[:origin],
          destination_nexus_id: fcl_params[:destination],
          dedicated_pricings_only: current_scope.fetch(:dedicated_pricings_only)
        ).perform

        render json: { data: equipment_classes }
      end

      private

      def fcl_params
        params.permit(:origin, :destination)
      end
    end
  end
end
