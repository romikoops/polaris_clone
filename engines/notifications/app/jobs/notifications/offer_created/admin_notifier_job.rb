# frozen_string_literal: true

module Notifications
  module OfferCreated
    class AdminNotifierJob < ApplicationJob
      prepend RailsEventStore::AsyncHandler

      def perform(event)
        offer = GlobalID.find(event.data.fetch(:offer))
        query = offer.query
        # Send offer created email
        Subscription.where(
          event_type: "Journey::OfferCreated",
          organization_id: event.data.fetch(:organization_id)
        ).filtered(FilterBuilder.new(offer: offer).to_hash).each do |subscription|
          AdminMailer.with(
            organization: query.organization,
            offer: offer,
            recipient: subscription.email || subscription.user.email
          ).offer_created.deliver_later
        end
      end
    end
  end
end
