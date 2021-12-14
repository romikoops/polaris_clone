# frozen_string_literal: true

module Api
  module V2
    class ShipmentRequestsController < ApiController
      def index
        render json: Api::V2::ShipmentRequestIndexSerializer.new(
          Api::V2::ShipmentRequestDecorator.decorate_collection(
            filtered_shipment_requests.paginate(pagination_params)
          )
        )
      end

      def show
        render json: Api::V2::ShipmentRequestSerializer.new(shipment_request)
      end

      def create
        render json: Api::V2::ShipmentRequestSerializer.new(shipment_request_creation_service.perform), status: :created
      end

      private

      def shipment_request_creation_service
        ShipmentRequestCreationService.new(
          result: result,
          shipment_request_params: shipment_request_params,
          commodity_info_params: commodity_info_params
        )
      end

      def shipment_request
        @shipment_request ||= Journey::ShipmentRequest.find(params[:id])
      end

      def filtered_shipment_requests
        @filterrific = initialize_filterrific(
          shipment_requests,
          filterrific_params
        ) || return

        shipment_requests.filterrific_find(@filterrific)
      end

      def shipment_requests
        @shipment_requests ||= Api::ShipmentRequest.where(client: current_user)
      end

      def creation_error_message
        "Please provide params of withInsurance, withCustomsHandling, status, "\
        "preferredVoyage, notes, commercialValueCents, commercialValueCurrency, contactsAttributes"
      end

      def shipment_request_params
        params.require(:shipmentRequest).permit(
          :withInsurance, :withCustomsHandling, :preferredVoyage, :notes,
          :commercialValueCents, :commercialValueCurrency, contactsAttributes: %i[
            addressLine1 addressLine2 addressLine3 city
            companyName countryCode email function geocodedAddress
            name phone point postalCode
          ]
        ).to_h.deep_transform_keys { |key| key.to_s.underscore.to_sym }
      end

      def commodity_info_params
        param_array = params.permit(commodityInfos: %i[description hsCode imoClass])[:commodityInfos] || []
        param_array.map { |commodity_info_param| commodity_info_param.to_h.deep_transform_keys { |key| key.to_s.underscore.to_sym } }
      end

      def result
        @result ||= Journey::Result.find(params[:result_id])
      end

      def index_params
        params.permit(:sortBy, :direction, :page, :perPage)
      end

      def filterrific_params
        {
          sorted_by: index_params[:sortBy] && index_params.values_at(:sortBy, :direction).compact.join("_")
        }
      end

      def pagination_params
        {
          page: [index_params[:page], 1].map(&:to_i).max,
          per_page: index_params[:perPage]
        }
      end
    end
  end
end
