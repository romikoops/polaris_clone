# frozen_string_literal: true

module Api
  module V1
    class QuotationSerializer < Api::V1::QuotationListSerializer
      attribute :completed

      attribute :containers do |quotation|
        ContainerSerializer.new(legacy_containers(quotation: quotation))
      end

      attribute :cargo_items do |quotation|
        CargoItemSerializer.new(legacy_cargo_items(quotation: quotation))
      end

      attribute :tenders do |quotation, params|
        TenderSerializer.new(quotation.tenders, params: { scope: params.dig(:scope) })
      end

      def self.legacy_containers(quotation:)
        return Legacy::Container.none if quotation.estimated

        Legacy::Container.where(
          id: quotation.cargo.units.where(legacy_type: "Legacy::Container").select(:legacy_id)
        )
      end

      def self.legacy_cargo_items(quotation:)
        return Legacy::CargoItem.none if quotation.estimated

        Legacy::CargoItem.where(
          id: quotation.cargo.units.where(legacy_type: "Legacy::CargoItem").select(:legacy_id)
        )
      end
    end
  end
end
