class SubscribeOrgsToOfferCreatedWorker
  include Sidekiq::Worker

  def perform(*args)
    Organizations::Organization.where(live: true).find_each do |organization|
      scope = organization.scope
      next if scope.content.dig("email_all_quotes").blank?

      theme = organization.theme
      Notifications::Subscription.create(
        email: theme.emails.dig("sales", "general"),
        organization: organization,
        event_type: "Journey::OfferCreated"
      )
    end
  end
end
