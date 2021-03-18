# frozen_string_literal: true

module Api
  module V1
    class ResultSerializer < Api::ApplicationSerializer
      attributes [:remarks, :carrier, :mode_of_transport, :id]
      attribute :origin do |result|
        result.query.origin
      end

      attribute :destination do |result|
        result.query.destination
      end

      attribute :service_level do |result|
        result.service
      end

      attribute :total do |result|
        {
          currency: result.total.currency.iso_code,
          amount: result.total.amount
        }
      end

      attribute :quotation_id do |result|
        result.result_set.query_id
      end

      attribute :transshipment do |result|
        result.itinerary.transshipment
      end

      attribute :estimated do |result|
        result.cargo_units.empty?
      end

      attribute :valid_until do |result|
        result.expiration_date
      end

      attribute :pickup_truck_type do |result|
        ""
      end

      attribute :delivery_truck_type do |result|
        ""
      end

      attribute :pickup_carrier do |result|
        result.pre_carriage_carrier
      end

      attribute :delivery_carrier do |result|
        result.on_carriage_carrier
      end

      attribute :pickup_service do |result|
        result.pre_carriage_service
      end

      attribute :delivery_service do |result|
        result.on_carriage_service
      end

      attribute :transit_time, if: proc { |_, params| !quotation_tool?(scope: params.dig(:scope)) }
      attribute :exchange_rates do |result|
        ::ResultFormatter::ExchangeRateService.new(
          base_currency: result.total.currency.iso_code,
          line_items: result.line_items
        ).perform
      end
    end
  end
end
