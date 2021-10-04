# frozen_string_literal: true

class BackfillNewDefaultToFilterInSubscriptionWorker
  include Sidekiq::Worker

  def perform
    Notifications::Subscription.find_each do |subscription|
      subscription.update(filter: {}) if subscription.filter == "{}"
    end
  end
end
