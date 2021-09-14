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

        render json: Api::V2::ShipmentRequestSerializer.new(shipment_request_service)
      end

      private

      def shipment_request_service
        shipment_request
      end

      def shipment_request
        Journey::ShipmentRequest.new(preferred_voyage: "FOO")
      end

      def creation_error_message
        "Please provide at least one param of result_id, additional_requirements, "\
        "customs, insurance, commercial_value, contact"
      end

      def shipment_request_params
        params.require(:shipment_request).permit(
          :result_id, :additional_requirements, :customs, :insurance,
          :commercial_value, :contact
        )
      end
    end
  end
end
