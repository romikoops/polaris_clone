# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class RequestsController < ApiController
      skip_before_action :doorkeeper_authorize!, only: [:create]

      def create
        Rails.configuration.event_store.publish(
          Journey::RequestCreated.new(data: {
            query: query.to_global_id,
            organization_id: Organizations.current_id,
            mode_of_transport: request_params[:mode_of_transport],
            note: request_params[:note]
          }),
          stream_name: "Organization$#{Organizations.current_id}"
        )
        render json: {status: 200}
      end

      private

      def query
        @query ||= Journey::Query.find(params[:query_id])
      end

      def request_params
        params.permit(
          :mode_of_transport,
          :query_id,
          :note
        )
      end
    end
  end
end
