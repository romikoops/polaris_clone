# frozen_string_literal: true

module Api
  module V2
    class ResultSerializer < Api::ApplicationSerializer
      attributes %i[
        id
        carrier
        carrier_logo
        modes_of_transport
        total
        service_level
        valid_until
        transit_time
        cargo_ready_date
        cargo_delivery_date
        origin
        destination
        transshipment
        number_of_stops
        query_id
      ]

      attribute :origin do |result|
        result.origin_route_point.name
      end

      attribute :destination do |result|
        result.destination_route_point.name
      end

      attribute :valid_until, &:expiration_date

      attribute :total do |result|
        {
          value: result.total.amount,
          currency: result.total.currency.iso_code
        }
      end

      attribute :cargo_ready_date do |result|
        result.query.cargo_ready_date
      end

      attribute :cargo_delivery_date do |result|
        result.query.delivery_date
      end
    end
  end
end
