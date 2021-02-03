# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class QueriesController < ApiController
      skip_before_action :doorkeeper_authorize!, only: [:create, :result_set, :show]

      def create
        new_query = wheelhouse_query_service.perform
        render json: Api::V2::RestfulSerializer.new(new_query)
      rescue Wheelhouse::ApplicationError => e
        render json: {error: e.message}, status: :unprocessable_entity
      end

      def show
        render json: Api::V2::QuerySerializer.new(
          Api::V2::QueryDecorator.new(query)
        )
      end

      def result_set
        render json: Api::V2::ResultSetSerializer.new(current_result_set)
      end

      private

      def query
        Journey::Query.find(params[:id] || params[:query_id])
      end

      def mock_user
        Users::Client.where(
          email: ["agent@itsmycargo.com"],
          organization: current_organization
        ).first
      end

      def current_result_set
        Journey::ResultSet.where(query: query).order(created_at: :desc).first
      end

      def wheelhouse_query_service
        Wheelhouse::QueryService.new(
          creator: mock_user,
          client: mock_user,
          source: mock_doorkeeper_application,
          params: query_params.to_h.deep_transform_keys { |key| key.to_s.underscore.to_sym }
        )
      end

      def mock_doorkeeper_application
        Doorkeeper::Application.find_by(name: "siren")
      end

      def query_params
        params.permit(
          :id,
          :originId,
          :destinationId,
          :loadType,
          :aggregated,
          items: [
            :default,
            :equipmentId,
            :cargoItemTypeId,
            :id,
            :quantity,
            :valid,
            :weight,
            :width,
            :height,
            :TotalVolume,
            :TotalWeight,
            :Volume,
            :Weight,
            :length,
            commodities: [:id, :code]
          ]
        )
      end
    end
  end
end
