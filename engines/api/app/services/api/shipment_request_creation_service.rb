# frozen_string_literal: true

module Api
  class ShipmentRequestCreationService
    attr_reader :shipment_request_params, :commodity_info_params

    def initialize(shipment_request_params:, commodity_info_params:)
      @shipment_request_params = shipment_request_params
      @commodity_info_params = commodity_info_params
    end

    def perform
      Journey::ShipmentRequest.create!(shipment_request_params).tap do |shipment_request|
        create_commodity_infos_through(shipment_request: shipment_request)
      end
    end

    private

    def create_commodity_infos_through(shipment_request:)
      cargo_units = Journey::CargoUnit.where(query_id: shipment_request.result.query_id).to_a

      cargo_units.product(commodity_info_params).each do |cargo_unit, commodity_info_param|
        Journey::CommodityInfo.create(commodity_info_param.merge(cargo_unit: cargo_unit))
      end
    end
  end
end
