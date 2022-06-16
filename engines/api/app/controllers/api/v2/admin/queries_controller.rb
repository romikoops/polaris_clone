# frozen_string_literal: true

module Api
  module V2
    module Admin
      class QueriesController < ApiController
        include UsersUserAccess

        def index
          render json: { errors: filter_params_validator.errors }, status: :unprocessable_entity and return unless filter_params_validator.valid?

          render json: Api::V2::QuerySerializer.new(
            Api::V2::QueryDecorator.decorate_collection(
              filtered_queries.paginate(pagination_params)
            )
          )
        end

        def index_params
          params.permit(:sortBy, :direction, :page, :perPage, :searchBy, :searchQuery)
        end

        def queries
          @queries ||= Api::Query.from_current_organization.where(company_id: params[:company_id])
        end

        def filtered_queries
          @filterrific = initialize_filterrific(
            queries,
            filter_params_validator.to_h
          ) || return

          queries.filterrific_find(@filterrific)
        end

        def pagination_params
          {
            page: [index_params[:page], 1].map(&:to_i).max,
            per_page: index_params[:perPage]
          }
        end

        def filter_params_validator
          @filter_params_validator ||= FilterParamValidator.new(
            Api::Query::SUPPORTED_SEARCH_OPTIONS,
            Api::Query::SUPPORTED_SORT_OPTIONS,
            Api::Query::DEFAULT_FILTER_PARAMS,
            options: index_params.transform_keys(&:underscore).to_h,
            search_query_options: { "load_type" => %w[fcl lcl] }
          )
        end
      end
    end
  end
end
