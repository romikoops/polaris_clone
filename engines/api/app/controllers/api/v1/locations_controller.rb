# frozen_string_literal: true

require_dependency "api/application_controller"

module Api
  module V1
    class LocationsController < ApiController
      def origins
        origin_nexuses = nexuses(target: :origin_destination)
        decorated_nexuses = NexusDecorator.decorate_collection(origin_nexuses)
        render json: NexusSerializer.new(decorated_nexuses)
      end

      def destinations
        destination_nexuses = nexuses(target: :destination_origin)
        decorated_nexuses = NexusDecorator.decorate_collection(destination_nexuses)
        render json: NexusSerializer.new(decorated_nexuses)
      end

      private

      def nexuses(target:)
        if location_params[:lat].present? && location_params[:lng].present?
          geo_routing(target: target)
        elsif location_params[:id].present?
          nexus_routing(target: target)
        else
          open_routing(target: target)
        end
      end

      def open_routing(target:)
        Api::Routing::RoutingService.nexuses(
          organization: current_organization,
          target: target,
          load_type: location_params[:load_type],
          query: location_params[:q]
        )
      end

      def nexus_routing(target:)
        Api::Routing::NexusRoutingService.nexuses(
          organization: current_organization,
          target: target,
          load_type: location_params[:load_type],
          query: location_params[:q],
          nexus_id: location_params[:id]
        )
      end

      def geo_routing(target:)
        Api::Routing::GeoRoutingService.nexuses(
          organization: current_organization,
          target: target,
          load_type: location_params[:load_type],
          query: location_params[:q],
          user: client,
          coordinates: coordinates
        )
      end

      def coordinates
        location_params.slice(:lat, :lng)
      end

      def location_params
        params.permit(:q, :id, :lat, :lng, :load_type, :client_id)
      end

      def client
        Users::Client.find_by(id: location_params[:client_id])
      end
    end
  end
end
