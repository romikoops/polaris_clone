# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V1
    class PortsController < ApiController
      ORIGIN_INDEX = 0
      DESTINATION_INDEX = 1

      skip_before_action :doorkeeper_authorize!, only: :index, raise: false

      def index
        render json: PortSerializer.new(hub_results)
      end

      private

      def ports_params
        required_params = %i[location_type]

        params.require(required_params)
        params.permit(*required_params, :location_id, :query)
      end

      def hub_results
        return hubs_for_location_type if ports_params[:query].blank?

        hubs_for_location_type.name_search(ports_params[:query])
      end

      def hubs_for_location_type
        @hubs_for_location_type ||= if ports_params[:location_type] == "origin"
          hubs.where(id: itineraries_for_type.select(:destination_hub_id))
        else
          hubs.where(id: itineraries_for_type.select(:origin_hub_id))
        end
      end

      def itineraries_for_type
        @itineraries_for_type ||= if ports_params[:location_id].present? && ports_params[:location_type] == "origin"
          itineraries.where(origin_hub_id: ports_params[:location_id])
        elsif ports_params[:location_id].present? && ports_params[:location_type] == "destination"
          itineraries.where(destination_hub_id: ports_params[:location_id])
        else
          itineraries
        end
      end

      def hubs
        @hubs ||= Legacy::Hub.where(organization: current_organization).order(:name)
      end

      def itineraries
        @itineraries ||= Legacy::Itinerary.where(organization: current_organization)
      end
    end
  end
end
