# frozen_string_literal: true

module Api
  module V1
    class QuerySerializer < Api::ApplicationSerializer
      attributes %i[completed load_type payment_terms company_name parent_id]

      attributes :selected_date, &:cargo_ready_date

      attribute :user do |query|
        query.client && UserSerializer.new(query.client)
      end

      attribute :creator do |query|
        UserSerializer.new(query.creator)
      end

      attribute :origin do |query|
        origin = if query.pre_carriage?
          query.pickup_address && AddressSerializer.new(query.pickup_address)
        else
          query.origin_nexus && NexusSerializer.new(query.origin_nexus)
        end

        origin || {}
      end

      attribute :destination do |query|
        destination = if query.on_carriage?
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
            query.results.map do |result|
              Api::V1::ResultDecorator.new(
                result,
                context: { scope: params[:scope] }
              )
            end,
            params: { scope: params[:scope] }
          )
      end
    end
  end
end
