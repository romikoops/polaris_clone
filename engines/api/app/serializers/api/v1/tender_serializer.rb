# frozen_string_literal: true

module Api
  module V1
    class TenderSerializer < Api::ApplicationSerializer
      set_id :uuid
      attributes %i[origin
                    destination
                    carrier
                    service_level
                    mode_of_transport
                    total
                    quotation_id
                    id
                    transshipment
                    estimated]
      attribute :transit_time, if: proc { |_, params| !quotation_tool?(scope: params.dig(:scope)) }
      attribute :exchange_rates do |tender|
        ::ResultFormatter::ExchangeRateService.new(tender: tender).perform
      end
    end
  end
end
