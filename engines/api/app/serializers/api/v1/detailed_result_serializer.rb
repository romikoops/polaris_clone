# frozen_string_literal: true

module Api
  module V1
    class DetailedResultSerializer < Api::ApplicationSerializer
      attributes %i[
        payment_terms
        charges
        route
        vessel
        id
      ]

      attribute :pickup_truck_type do |result|
      end

      attribute :delivery_truck_type do |result|
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
    end
  end
end
