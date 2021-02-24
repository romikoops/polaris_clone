# frozen_string_literal: true

module OfferCalculator
  class AsyncCalculationJob < ApplicationJob
    queue_as :critical

    def perform(query:, params:, shipment_id: nil, quotation_id: nil, user_id: nil, wheelhouse: nil, mailer: nil)
      return if shipment_id.present?

      Organizations.current_id = query.organization_id

      set_sentry_context(query)

      OfferCalculator::Results.new(
        query: query,
        params: params
      ).perform
    end

    private

    def set_sentry_context(query)
      scope = Sentry.get_current_scope

      scope.set_tags(
        billable: query.billable,
        organization: query.organization.slug,
        source: Doorkeeper::Application.find_by(id: query.source_id)&.name
      )
      scope.set_user(id: query.creator_id, email: query.creator&.email)

      scope.set_context(:destination, query.destination)
      scope.set_context(:load_type, query.load_type)
      scope.set_context(:origin, query.origin)
    end
  end
end
