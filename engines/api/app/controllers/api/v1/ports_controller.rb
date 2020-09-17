# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V1
    class PortsController < ApiController
      ORIGIN_INDEX = 0
      DESTINATION_INDEX = 1

      skip_before_action :doorkeeper_authorize!, only: :index, raise: false

      def index
        hub_ids = Legacy::Stop.select(:hub_id)
          .where(itinerary_id: ports_itineraries,
                 index: stop_index_if_location_selected)

        hubs = Legacy::Hub.where(id: hub_ids)
          .order(:name)

        hubs = hubs.name_search(ports_params[:query]) unless ports_params[:query].empty?

        render json: PortSerializer.new(hubs)
      end

      private

      def ports_params
        required_params = %i[location_type]

        params.require(required_params)
        params.permit(*required_params, :location_id, :query)
      end

      def default_stop_index
        ports_params[:location_type] == "origin" ? ORIGIN_INDEX : DESTINATION_INDEX
      end

      def stop_index_if_location_selected
        return default_stop_index unless ports_params[:location_id]

        ports_params[:location_type] == "origin" ? DESTINATION_INDEX : ORIGIN_INDEX
      end

      def ports_itineraries
        itineraries = Legacy::Itinerary.joins(:stops)
          .where(organization_id: current_organization.id,
                 mode_of_transport: "ocean",
                 stops: { index: default_stop_index })

        hub_id = ports_params[:location_id]
        itineraries = itineraries.where(stops: { hub_id: hub_id }) if hub_id.present?

        itineraries
      end
    end
  end
end
