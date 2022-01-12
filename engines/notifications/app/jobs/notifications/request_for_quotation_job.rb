# frozen_string_literal: true

module Notifications
  class RequestForQuotationJob < ApplicationJob
    prepend RailsEventStore::AsyncHandler

    def perform(event)
      query = GlobalID.find(event.data.fetch(:query_id))
      request_for_quotation = GlobalID.find(event.data.fetch(:request_for_quotation_id))

      Subscription.where(
        event_type: "Journey::RequestCreated",
        organization_id: query.organization_id
      ).find_each do |subscription|
        RequestMailer.with(
          organization: subscription.organization,
          query: query,
          request_for_quotation: request_for_quotation,
          recipient: subscription.email || subscription.user.email
        ).request_created.deliver_later
      end
    end
  end
end
