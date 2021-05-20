# frozen_string_literal: true

module Api
  module V1
    class ResultSerializer < Api::ApplicationSerializer
      attributes %i[remarks carrier mode_of_transport id]
      attribute :origin do |result|
        result.query.origin
      end

      attribute :destination do |result|
        result.query.destination
      end

      attribute :origin_hub, &:origin

      attribute :destination_hub, &:destination

      attribute :pickup_address do |result|
        result.pickup_address&.geocoded_address
      end
      attribute :delivery_address do |result|
        result.delivery_address&.geocoded_address
      end

      attribute :service_level, &:service

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

      attribute :valid_until, &:expiration_date

      attribute :pickup_truck_type do |_result|
        ""
      end

      attribute :delivery_truck_type do |_result|
        ""
      end

      attribute :pickup_carrier, &:pre_carriage_carrier

      attribute :delivery_carrier, &:on_carriage_carrier

      attribute :pickup_service, &:pre_carriage_service

      attribute :delivery_service, &:on_carriage_service

      attribute :transit_time, if: proc { |_, params| !quotation_tool?(scope: params[:scope]) }
      attribute :exchange_rates do |result|
        ::ResultFormatter::ExchangeRateService.new(
          line_items: result.line_items
        ).perform
      end
    end
  end
end
