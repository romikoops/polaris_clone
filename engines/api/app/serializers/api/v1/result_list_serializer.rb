# frozen_string_literal: true

module Api
  module V1
    class ResultListSerializer < Api::ApplicationSerializer
      attributes [:selected_date, :load_type, :id]

      attribute :user do |result|
        UserSerializer.new(result.client)
      end

      attribute :origin do |result|
        if result.query.pickup_address.present?
          AddressSerializer.new(result.query.pickup_address)
        else
          NexusSerializer.new(result.query.origin_nexus)
        end
      end

      attribute :destination do |result|
        if result.query.delivery_address.present?
          AddressSerializer.new(result.query.delivery_address)
        else
          NexusSerializer.new(result.query.destination_nexus)
        end
      end
    end
  end
end
