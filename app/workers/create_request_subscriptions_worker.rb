class CreateRequestSubscriptionsWorker
  include Sidekiq::Worker

  def perform(*args)
    Organizations::Organization.where(live: true).find_each do |organization|
      theme = organization.theme
      email = theme.emails.dig("sales", "general")
      next if email.blank?

      Notifications::Subscription.create(
        email: email,
        organization: organization,
        event_type: "Journey::RequestCreated"
      )
    end
  end
end
