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
      Journey::ShipmentRequest.create!(shipment_request_attributes).tap do |shipment_request|
        create_commodity_infos_through(shipment_request: shipment_request)
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
        contacts_attributes: shipment_request_params[:contacts_attributes].map do |params|
          # rubocop:disable Naming/VariableNumber
          params[:address_line_1] = params.delete(:address_line1)
          params[:address_line_2] = params.delete(:address_line2)
          params[:address_line_3] = params.delete(:address_line3)
          # rubocop:enable Naming/VariableNumber
          params
        end
      )
    end
  end
end
