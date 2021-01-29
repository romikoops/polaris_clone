# frozen_string_literal: true

module Api
  module V2
    class ResultSerializer < Api::ApplicationSerializer
      attributes [
        :id,
        :carrier,
        :modes_of_transport,
        :schedules,
        :total,
        :service_level,
        :valid_until,
        :transit_time,
        :cargo_ready_date,
        :cargo_delivery_date,
        :origin,
        :destination
      ]

      attribute :origin do |result|
        result.origin_route_point.name
      end

      attribute :destination do |result|
        result.destination_route_point.name
      end

      attribute :service_level do |result|
        result.service
      end

      attribute :modes_of_transport do |result|
        result.route_sections.pluck(:mode_of_transport).uniq
      end

      attribute :valid_until do |result|
        result.expiration_date
      end

      attribute :total do |result|
        {
          value: result.total.amount,
          currency: result.total.currency.iso_code
        }
      end

      attribute :schedules do
        []
      end

      attribute :transit_time do |result|
        result.transit_time
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
