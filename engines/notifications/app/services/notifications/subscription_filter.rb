# frozen_string_literal: true

module Notifications
  class SubscriptionFilter
    attr_reader :results, :event

    def initialize(event:, results:)
      @event = event
      @results = results
    end

    def subscriptions
      Subscription.where(
        event_type: event.event_type,
        organization_id: event.data.fetch(:organization_id)
      ).select do |subscription|
        email_subscribed?(subscription: subscription)
      end
    end

    private

    def email_subscribed?(subscription:)
      subscription.filter.empty? ||
        offer_filter_hash.any? do |filter_key, filter_list|
          filter_list.any?(subscription.send(filter_key))
        end
    end

    def offer_filter_hash
      @offer_filter_hash ||= FilterBuilder.new(results: results).to_hash
    end
  end
end
