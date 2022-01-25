# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class QueriesController < ApiController
      skip_before_action :doorkeeper_authorize!, only: %i[create result_set show]

      def index
        render json: index_search_response and return if [search_by, search_query].all?(&:blank?)
        render json: { error: "'searchQuery' must not be blank when providing 'searchBy'" }, status: :unprocessable_entity and return if search_query.blank?
        render json: { error: "#{search_by} is not a valid 'searchBy' option" }, status: :unprocessable_entity and return unless index_search_by_option_valid?
        render json: { error: "#{search_query} is not a valid 'load_type' option" }, status: :unprocessable_entity and return unless index_search_query_valid?

        render json: index_search_response
      end

      def create
        return head :unprocessable_entity if query_params[:items].blank?

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

      def update
        query_is_editable = query.client_id.nil? && query.creator_id.nil?
        return head :unauthorized unless query_is_editable && (query.organization == current_organization)

        query.update(client: organization_user, company: organization_user.company, creator: organization_user)
        render json: Api::V2::QuerySerializer.new(
          Api::V2::QueryDecorator.new(query)
        )
      end

      def result_set
        render json: Api::V2::QueryStatusSerializer.new(query)
      end

      private

      def index_search_response
        Api::V2::QuerySerializer.new(
          Api::V2::QueryDecorator.decorate_collection(
            filtered_queries.paginate(
              page: index_params[:page],
              per_page: index_params[:perPage]
            )
          )
        )
      end

      def index_search_by_option_valid?
        search_by.in?(%w[
          parent_id
          load_type
          reference
          client_email
          client_name
          company_name
          origin
          destination
          imo_class
          hs_code
          billable
        ])
      end

      def index_search_query_valid?
        return true if search_by != "load_type"

        search_query.in?(%w[fcl lcl])
      end

      def filterrific_params
        {
          sorted_by: sort_by && [sort_by, index_params[:direction]].compact.join("_"),
          "#{search_by}_search": search_by && search_query
        }.compact
      end

      def filtered_queries
        queries = Api::Query.where(
          client: current_user,
          organization_id: current_organization.id,
          status: "completed"
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
          :parentId,
          :aggregated,
          :billable,
          :cargoReadyDate,
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
            { commodities: %i[description hsCode imoClass] }
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
        params.permit(:sortBy, :direction, :page, :perPage, :searchBy, :searchQuery)
      end

      def sort_by
        index_params[:sortBy]
      end

      def search_query
        index_params[:searchQuery]
      end

      def search_by
        index_params[:searchBy]
      end
    end
  end
end
