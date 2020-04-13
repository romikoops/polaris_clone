# frozen_string_literal: true

module Api
  module V1
    class QuotationSerializer < Api::ApplicationSerializer
      attributes :selected_date

      attribute :load_type do |quotation|
        quotation.tenders.first&.load_type
      end

      attribute :user do |quotation|
        UserSerializer.new(quotation.tenants_user)
      end

      attribute :origin do |quotation|
        if quotation.pickup_address.present?
          AddressSerializer.new(quotation.pickup_address)
        else
          NexusSerializer.new(quotation.origin_nexus)
        end
      end

      attribute :destination do |quotation|
        if quotation.delivery_address.present?
          AddressSerializer.new(quotation.delivery_address)
        else
          NexusSerializer.new(quotation.destination_nexus)
        end
      end

      attribute :containers do |quotation|
        ContainerSerializer.new(quotation.shipment.containers)
      end

      attribute :cargo_items do |quotation|
        CargoItemSerializer.new(quotation.shipment.cargo_items)
      end

      attribute :tenders do |quotation, params|
        TenderSerializer.new(quotation.tenders, params: { scope: params.dig(:scope) })
      end
    end
  end
end
