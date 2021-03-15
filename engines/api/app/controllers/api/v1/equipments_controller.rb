# frozen_string_literal: true

module Api
  module V1
    class EquipmentsController < ApiController
      def index
        equipment_classes = Wheelhouse::EquipmentService.new(
          user: current_user,
          organization: current_organization,
          origin: location(target: "origin"),
          destination: location(target: "destination"),
          dedicated_pricings_only: current_scope.fetch(:dedicated_pricings_only)
        ).perform

        render json: {data: equipment_classes}
      end

      private

      def location(target:)
        {
          nexus_id: fcl_params["#{target}_nexus_id"],
          latitude: fcl_params["#{target}_latitude"],
          longitude: fcl_params["#{target}_longitude"]
        }
      end

      def fcl_params
        params.permit(:origin,
          :destination,
          :origin_latitude,
          :origin_longitude,
          :origin_nexus_id,
          :destination_latitude,
          :destination_longitude,
          :destination_nexus_id)
      end
    end
  end
end
