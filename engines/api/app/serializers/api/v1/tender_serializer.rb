# frozen_string_literal: true

module Api
  module V1
    class TenderSerializer < Api::ApplicationSerializer
      attributes %i[origin
                    destination
                    carrier
                    service_level
                    mode_of_transport
                    total
                    quotation_id
                    id
                    transshipment
                    estimated
                    valid_until
                    remarks
                    pickup_truck_type
                    delivery_truck_type
                    pickup_carrier
                    delivery_carrier
                    pickup_service
                    delivery_service]
      attribute :transit_time, if: proc { |_, params| !quotation_tool?(scope: params.dig(:scope)) }
      attribute :exchange_rates do |tender|
        ::ResultFormatter::ExchangeRateService.new(tender: tender).perform
      end
    end
  end
end
