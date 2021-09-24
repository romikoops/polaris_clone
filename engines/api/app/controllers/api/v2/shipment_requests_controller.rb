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
          shipment_request_params: shipment_request_params,
          commodity_info_params: commodity_info_params
        )
      end

      def shipment_request
        @shipment_request ||= Journey::ShipmentRequest.find(params[:id])
      end

      def creation_error_message
        "Please provide params of result_id, company_id, client_id, with_insurance, with_customs_handling, status, "\
        "preferred_voyage, notes, commercial_value_cents, commercial_value_currency, contacts_attributes"
      end

      def shipment_request_params
        # rubocop:disable Naming/VariableNumber
        params.require(:shipment_request).permit(
          :result_id, :company_id, :client_id, :with_insurance,
          :with_customs_handling, :status, :preferred_voyage, :notes,
          :commercial_value_cents, :commercial_value_currency, contacts_attributes: %i[
            address_line_1 address_line_2 address_line_3 city
            company_name country_code email function geocoded_address
            name phone point postal_code
          ]
        )
        # rubocop:enable Naming/VariableNumber
      end

      def commodity_info_params
        params.require(:commodity_infos).map do |commodity_info|
          commodity_info.permit(:description, :hs_code, :imo_class).to_hash
        end
      end
    end
  end
end
