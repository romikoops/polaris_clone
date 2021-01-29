# frozen_string_literal: true

module OfferCalculator
  class AsyncCalculationJob < ApplicationJob
    queue_as :critical

    def perform(query:, params:, shipment_id: nil, quotation_id: nil, user_id: nil, wheelhouse: nil, mailer: nil)
      return if shipment_id.present?

      Organizations.current_id = query.organization_id
      OfferCalculator::Results.new(
        query: query,
        params: params
      ).perform
    end
  end
end
