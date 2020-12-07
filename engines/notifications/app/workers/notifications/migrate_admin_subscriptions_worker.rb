module Notifications
  class MigrateAdminSubscriptionsWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker

    def perform
      total ::Organizations::Organization.count

      ::Organizations::Organization.find_each.with_index do |organization, index|
        at(index + 1)

        email = organization.theme.emails.dig("sales", "general")

        next unless ::OrganizationManager::ScopeService.new(organization: organization)
          .fetch(:email_on_registration)
        next if email.blank?
        next if Notifications::Subscription.exists?(
          event_type: "Users::UserCreated", email: email, organization: organization
        )

        Notifications::Subscription.create!(
          event_type: "Users::UserCreated", email: email, organization: organization
        )
      end
    end
  end
end
