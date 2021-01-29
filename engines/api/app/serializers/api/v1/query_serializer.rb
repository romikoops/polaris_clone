# frozen_string_literal: true

module Api
  module V1
    class QuerySerializer < Api::ApplicationSerializer
      attribute :completed do |query|
        query.completed
      end

      attributes :selected_date do |query|
        query.cargo_ready_date
      end

      attribute :load_type do |query|
        query.load_type
      end

      attribute :user do |query|
        query.client && UserSerializer.new(UserDecorator.new(query.client))
      end

      attribute :origin do |query|
        origin = if query.has_pre_carriage?
          query.pickup_address && AddressSerializer.new(query.pickup_address)
        else
          query.origin_nexus && NexusSerializer.new(query.origin_nexus)
        end

        origin || {}
      end

      attribute :destination do |query|
        destination = if query.has_on_carriage?
          query.delivery_address && AddressSerializer.new(query.delivery_address)
        else
          query.destination_nexus && NexusSerializer.new(query.destination_nexus)
        end

        destination || {}
      end

      attribute :containers do |query|
        FclCargoUnitSerializer.new(query.containers)
      end

      attribute :cargo_items do |query|
        LclCargoUnitSerializer.new(query.cargo_items)
      end

      attribute :tenders do |query, params|
        query.results &&
          ResultSerializer.new(
            query.results.map { |result|
              Api::V1::ResultDecorator.new(
                result,
                context: {scope: params.dig(:scope)}
              )
            },
            params: {scope: params.dig(:scope)}
          )
      end
    end
  end
end
