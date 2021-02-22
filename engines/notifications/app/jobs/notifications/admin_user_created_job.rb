# frozen_string_literal: true
module Notifications
  class AdminUserCreatedJob < ApplicationJob
    prepend RailsEventStore::AsyncHandler

    def perform(event)
      user = GlobalID.find(event.data.fetch(:user))

      # Find all subscriptions
      Subscription.where(
        event_type: "Users::UserCreated",
        organization_id: event.data.fetch(:organization_id)
      ).find_each do |subscription|
        AdminMailer.with(
          organization: subscription.organization,
          user: user,
          profile: user.profile,
          recipient: subscription.email || subscription.user.email
        ).user_created.deliver_later
      end
    end
  end
end
