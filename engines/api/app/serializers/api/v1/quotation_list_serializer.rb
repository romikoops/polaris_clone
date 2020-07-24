# frozen_string_literal: true

module Api
  module V1
    class QuotationListSerializer < Api::ApplicationSerializer
      attributes :selected_date

      attribute :load_type do |quotation|
        quotation.tenders.first&.load_type
      end

      attribute :user do |quotation|
        UserSerializer.new(quotation.user)
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
    end
  end
end
