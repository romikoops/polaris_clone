# frozen_string_literal: true

module Notifications
  module OfferCreated
    class AdminNotifierJob < ApplicationJob
      prepend RailsEventStore::AsyncHandler
      attr_reader :offer

      def perform(event)
        @offer = GlobalID.find(event.data.fetch(:offer))
        query = offer.query

        # Send offer created email
        Subscription.where(
          event_type: "Journey::OfferCreated",
          organization_id: event.data.fetch(:organization_id)
        ).find_each do |subscription|
          next unless email_subscribed?(subscription: subscription)

          AdminMailer.with(
            organization: query.organization,
            offer: offer,
            recipient: subscription.email || subscription.user.email
          ).offer_created.deliver_later
        end
      end

      private

      def offer_filter_hash
        @offer_filter_hash ||= FilterBuilder.new(offer: offer).to_hash
      end

      def email_subscribed?(subscription:)
        subscription.filter.empty? ||
          offer_filter_hash.any? do |filter_key, filter_list|
            filter_list.any?(subscription.send(filter_key))
          end
      end
    end
  end
end
