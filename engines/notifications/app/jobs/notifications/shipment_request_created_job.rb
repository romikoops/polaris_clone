# frozen_string_literal: true

module Notifications
  class ShipmentRequestCreatedJob < ApplicationJob
    prepend RailsEventStore::AsyncHandler

    def perform(event)
      @shipment_request = GlobalID.find(event.data.fetch(:shipment_request))
      subscriptions(event: event).each do |subscription|
        AdminMailer.with(
          organization: Organizations::Organization.find(event.data.fetch(:organization_id)),
          shipment_request: @shipment_request,
          recipient: subscription.email || subscription.user.email
        ).shipment_request_created.deliver_later
      end
    end

    private

    def subscriptions(event:)
      SubscriptionFilter.new(
        event: event,
        results: Journey::Result.where(id: @shipment_request.result_id)
      ).subscriptions
    end
  end
end
