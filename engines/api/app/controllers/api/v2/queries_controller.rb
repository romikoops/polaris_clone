# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class QueriesController < ApiController
      skip_before_action :doorkeeper_authorize!, only: %i[create result_set show]

      def index
        render json: Api::V2::QuerySerializer.new(
          Api::V2::QueryDecorator.decorate_collection(
            filtered_queries.paginate(
              page: index_params[:page],
              per_page: index_params[:per_page]
            )
          )
        )
      end

      def create
        new_query = wheelhouse_query_service.perform
        decorated = Api::V2::QueryDecorator.decorate(new_query)
        render json: Api::V2::QuerySerializer.new(decorated), status: :created
      rescue Wheelhouse::ApplicationError => e
        render json: { error: e.message }, status: :unprocessable_entity
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

      def filterrific_params
        return {} if index_params[:sort_by].blank?

        { sorted_by: [index_params[:sort_by], index_params[:direction]].compact.join("_") }
      end

      def filtered_queries
        queries = Api::Query.joins(:result_sets).where(
          client: current_user,
          organization_id: current_organization.id,
          journey_result_sets: { status: "completed" }
        )

        @filterrific = initialize_filterrific(
          queries,
          filterrific_params
        ) || return

        queries.filterrific_find(@filterrific)
      end

      def query
        @query ||= Journey::Query.find(params[:id] || params[:query_id])
      end

      def current_result_set
        Journey::ResultSet.where(query: query).order(created_at: :desc).first
      end

      def wheelhouse_query_service
        Wheelhouse::QueryService.new(
          creator: current_user,
          client: current_user,
          source: mock_doorkeeper_application,
          params: query_service_params
        )
      end

      def mock_doorkeeper_application
        Doorkeeper::Application.find_by(name: "siren")
      end

      def query_service_params
        query_params
          .to_h
          .deep_transform_keys { |key| key.to_s.underscore.to_sym }
      end

      def query_params
        params.permit(
          :originId,
          :destinationId,
          :loadType,
          :aggregated,
          items: [
            :cargoClass,
            :stackable,
            :dangerous,
            :colliType,
            :quantity,
            :width,
            :height,
            :length,
            :volume,
            :weight,
            { commodities: %i[description hs_code imo_class] }
          ]
        )
      end

      def request_params
        params.permit(
          :mode_of_transport,
          :query_id,
          :note
        )
      end

      def index_params
        params.permit(:sort_by, :direction, :page, :per_page)
      end
    end
  end
end
