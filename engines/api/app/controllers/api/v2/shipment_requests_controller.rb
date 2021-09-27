# frozen_string_literal: true

module Api
  module V2
    class ShipmentRequestsController < ApiController
      def show
        render json: Api::V2::ShipmentRequestSerializer.new(shipment_request)
      end

      def create
        if shipment_request_params.empty?
          return render(
            json: { error: creation_error_message },
            status: :unprocessable_entity
          )
        end

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
        params.permit(commodityInfos: %i[description hsCode imoClass])[:commodityInfos]
          .map { |commodity_info_param| commodity_info_param.to_h.deep_transform_keys { |key| key.to_s.underscore.to_sym } }
      end

      def result
        @result ||= Journey::Result.find(params[:result_id])
      end
    end
  end
end
