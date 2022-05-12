# frozen_string_literal: true

module Api
  module V2
    module Admin
      class ClientsController < ApiController
        include UsersUserAccess

        def index
          render json: { errors: filter_params_validator.errors }, status: :unprocessable_entity and return unless filter_params_validator.valid?

          render json: Api::V2::ClientSerializer.new(
            Api::V2::ClientDecorator.decorate_collection(
              filtered_clients.paginate(pagination_params)
            )
          )
        end

        private

        def index_params
          params.permit(:sortBy, :direction, :page, :perPage, :searchBy, :searchQuery, :beforeDate, :afterDate).transform_keys(&:underscore)
        end

        def pagination_params
          {
            page: [index_params[:page], 1].map(&:to_i).max,
            per_page: index_params[:per_page]
          }
        end

        def clients_by_company
          @clients_by_company = Api::Client.where(organization_id: params[:organization_id]).from_company(params[:company_id])
        end

        def filtered_clients
          @filterrific = initialize_filterrific(
            clients_by_company,
            filter_params_validator.to_h
          ) || return

          clients_by_company.filterrific_find(@filterrific)
        end

        def filter_params_validator
          @filter_params_validator ||= FilterParamValidator.new(
            Api::Client::SUPPORTED_SEARCH_OPTIONS,
            Api::Client::SUPPORTED_SORT_OPTIONS,
            options: index_params.to_h
          )
        end
      end
    end
  end
end
