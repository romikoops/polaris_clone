# frozen_string_literal: true

module Api
  module V1
    class QuotationSerializer < Api::V1::QuotationListSerializer
      attribute :containers do |quotation|
        ContainerSerializer.new(Legacy::Container.where(shipment_id: quotation.legacy_shipment_id))
      end

      attribute :cargo_items do |quotation|
        CargoItemSerializer.new(Legacy::CargoItem.where(shipment_id: quotation.legacy_shipment_id))
      end

      attribute :tenders do |quotation, params|
        TenderSerializer.new(quotation.tenders, params: { scope: params.dig(:scope) })
      end
    end
  end
end
