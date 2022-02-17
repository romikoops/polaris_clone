# frozen_string_literal: true

module OfferCalculator
  class AsyncCalculationJob < ApplicationJob
    queue_as :critical

    def perform(query:, params:, pre_carriage: nil, on_carriage: nil)
      return if [pre_carriage, on_carriage].all?(&:nil?)

      Organizations.current_id = query.organization_id
      set_sentry_context(query)

      OfferCalculator::Results.new(
        query: query,
        params: params,
        pre_carriage: pre_carriage,
        on_carriage: on_carriage
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

      scope.set_context("offer_calculation", {
        destination: query.destination,
        load_type: query.load_type,
        origin: query.origin
      })
    end
  end
end
