# frozen_string_literal: true

module Api
  module V2
    module Admin
      class ShipmentRequestsController < ApiController
        include UsersUserAccess

        def index
          render json: { errors: filter_params_validator.errors }, status: :unprocessable_entity and return unless filter_params_validator.valid?

          render json: Api::V2::Admin::ShipmentRequestIndexSerializer.new(
            Api::V2::ShipmentRequestDecorator.decorate_collection(
              filtered_shipment_requests.paginate(pagination_params)
            )
          )
        end

        def index_params
          params.permit(:sortBy, :direction, :page, :perPage, :searchBy, :searchQuery)
        end

        def shipment_requests
          @shipment_requests ||= Api::ShipmentRequest.where(company_id: params[:company_id])
        end

        def filtered_shipment_requests
          @filterrific = initialize_filterrific(
            shipment_requests,
            filter_params_validator.to_h
          ) || return

          shipment_requests.filterrific_find(@filterrific)
        end

        def pagination_params
          {
            page: [index_params[:page], 1].map(&:to_i).max,
            per_page: index_params[:perPage]
          }
        end

        def filter_params_validator
          @filter_params_validator ||= FilterParamValidator.new(
            Api::ShipmentRequest::SUPPORTED_SEARCH_OPTIONS,
            Api::ShipmentRequest::SUPPORTED_SORT_OPTIONS,
            Api::ShipmentRequest::DEFAULT_FILTER_PARAMS,
            options: index_params.transform_keys(&:underscore).to_h
          )
        end
      end
    end
  end
end
