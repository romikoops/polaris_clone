# frozen_string_literal: true
module Notifications
  class RequestCreatedJob < ApplicationJob
    prepend RailsEventStore::AsyncHandler

    def perform(event)
      query = GlobalID.find(event.data.fetch(:query))

      Subscription.where(
        event_type: "Journey::RequestCreated",
        organization_id: event.data.fetch(:organization_id)
      ).find_each do |subscription|
        RequestMailer.with(
          organization: subscription.organization,
          query: query,
          mode_of_transport: event.data.fetch(:mode_of_transport),
          note: event.data.fetch(:note),
          recipient: subscription.email || subscription.user.email
        ).request_created.deliver_later
      end
    end
  end
end
