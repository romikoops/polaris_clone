# frozen_string_literal: true

require_dependency 'api/api_controller'

module Api
  module V1
    class QuotationsController < ApiController
      def create
        render json: quotation_service.tenders, each_serializer: TenderSerializer, scope: current_scope
      end

      def download
        document = Wheelhouse::PdfService.new(tenders: download_params[:tenders]).download
        render json: document, serializer: PdfSerializer
      end

      private

      def quotation_service
        Wheelhouse::QuotationService.new(quotation_details: quotation_params, shipping_info: shipment_params)
      end

      def quotation_params
        params.require(:quote).permit(
          :selected_date,
          :user_id,
          :tenant_id,
          :load_type,
          :delay,
          origin: [*address_params, hub_ids: []],
          destination: [*address_params, hub_ids: []]
        )
      end

      def shipment_params
        cargo_items_attributes = %i[payload_in_kg dimension_x dimension_y
                                    dimension_z quantity total_weight total_volume
                                    stackable cargo_item_type_id dangerous_goods cargo_class]
        params.require(:shipment_info).permit(cargo_items_attributes: cargo_items_attributes,
                                              container_attributes: %i[size_class quantity
                                                                       payload_in_kg dangerous_goods cargo_class],
                                              trucking_info: [pre_carriage: [:truck_type], on_carriage: [:truck_type]])
      end

      def address_params
        %i[name zip_code number city country full_address latitude longitude nexus_id nexus_name]
      end

      def download_params
        params.permit(tenders: %i[shipmentId chargeTripId])
      end
    end
  end
end
