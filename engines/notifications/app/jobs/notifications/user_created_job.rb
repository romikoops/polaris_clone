module Notifications
  class UserCreatedJob < ApplicationJob
    prepend RailsEventStore::AsyncHandler

    def perform(event)
      user = GlobalID.find(event.data.fetch(:user))

      return if user.activation_state == "active"

      # Send confirmation email
      UserMailer.with(
        organization: ::Organizations::Organization.find(user.organization_id),
        user: user,
        profile: user.profile
      ).activation_needed_email.deliver_later
    end
  end
end
