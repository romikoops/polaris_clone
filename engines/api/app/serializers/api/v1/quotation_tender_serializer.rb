# frozen_string_literal: true

module Api
  module V1
    class QuotationTenderSerializer < Api::ApplicationSerializer
      attributes %i[
        charges
        route
        vessel
        id
        pickup_truck_type
        delivery_truck_type
        pickup_carrier
        delivery_carrier
        pickup_service
        delivery_service
      ]
      attribute :transit_time, if: proc { |_, params| !quotation_tool?(scope: params.dig(:scope)) }
    end
  end
end
