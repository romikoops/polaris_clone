# frozen_string_literal: true

module Api
  class ShipmentRequestCreationService
    attr_reader :result, :shipment_request_params, :commodity_info_params

    def initialize(result:, shipment_request_params:, commodity_info_params:)
      @result = result
      @shipment_request_params = shipment_request_params
      @commodity_info_params = commodity_info_params
    end

    def perform
      ActiveRecord::Base.transaction do
        Journey::ShipmentRequest.new(shipment_request_attributes).tap do |shipment_request|
          return shipment_request unless shipment_request.save

          create_commodity_infos_through(shipment_request: shipment_request)
          Pdf::Shipment::Request.new(shipment_request: shipment_request).file
          publish_event_for(shipment_request: shipment_request)
        end
      end
    end

    private

    delegate :query, to: :result

    def create_commodity_infos_through(shipment_request:)
      cargo_units = Journey::CargoUnit.where(query_id: shipment_request.result.query_id).to_a

      cargo_units.product(commodity_info_params).each do |cargo_unit, commodity_info_param|
        Journey::CommodityInfo.create(commodity_info_param.merge(cargo_unit: cargo_unit))
      end
    end

    def shipment_request_attributes
      shipment_request_params.merge(
        status: Journey::ShipmentRequest.statuses["requested"],
        result: result,
        client_id: query.client_id,
        company_id: query.company_id,
        contacts_attributes: contacts_attributes,
        with_insurance: boolean_from_param(value: shipment_request_params[:with_insurance]),
        with_customs_handling: boolean_from_param(value: shipment_request_params[:with_customs_handling]),
        documents: documents
      )
    end

    def contacts_attributes
      (shipment_request_params[:contacts_attributes] || []).map do |params|
        # rubocop:disable Naming/VariableNumber
        params[:address_line_1] = params.delete(:address_line1)
        params[:address_line_2] = params.delete(:address_line2)
        params[:address_line_3] = params.delete(:address_line3)
        # rubocop:enable Naming/VariableNumber
        params
      end
    end

    def publish_event_for(shipment_request:)
      Rails.configuration.event_store.publish(
        Journey::ShipmentRequestCreated.new(data: {
          shipment_request: shipment_request.to_global_id, organization_id: Organizations.current_id
        }),
        stream_name: "Organization$#{Organizations.current_id}"
      )
    end

    def documents
      return [] if shipment_request_params[:documents].blank?

      shipment_request_params[:documents].map do |file|
        Journey::Document.new(query: query, file: file)
      end
    end

    def boolean_from_param(value:)
      return false if value.nil?

      ActiveModel::Type::Boolean.new.cast(value)
    end
  end
end
