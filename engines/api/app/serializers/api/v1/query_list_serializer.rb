# frozen_string_literal: true

module Api
  module V1
    class QueryListSerializer < Api::ApplicationSerializer
      attributes :load_type

      attributes :selected_date, &:cargo_ready_date

      attribute :user do |query|
        UserSerializer.new(query.client)
      end

      attribute :creator do |query|
        UserSerializer.new(query.creator)
      end

      attribute :origin do |query|
        if query.pickup_address.present?
          AddressSerializer.new(query.pickup_address)
        else
          NexusSerializer.new(query.origin_nexus)
        end
      end

      attribute :destination do |query|
        if query.delivery_address.present?
          AddressSerializer.new(query.delivery_address)
        else
          NexusSerializer.new(query.destination_nexus)
        end
      end
    end
  end
end
