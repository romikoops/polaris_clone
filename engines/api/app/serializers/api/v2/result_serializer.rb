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

      attribute :pre_carriage do |result|
        result.pre_carriage_section.present?
      end

      attribute :on_carriage do |result|
        result.on_carriage_section.present?
      end

      attribute :valid_until, &:expiration_date

      attribute :total do |result|
        total = result.total
        if total.present?
          value = total.amount
          currency = total.currency.iso_code
        end
        %i[value currency].zip([value, currency]).to_h
      end
    end
  end
end
