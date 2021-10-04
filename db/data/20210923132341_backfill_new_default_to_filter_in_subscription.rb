# frozen_string_literal: true

class BackfillNewDefaultToFilterInSubscription < ActiveRecord::Migration[5.2]
  def up
    BackfillNewDefaultToFilterInSubscriptionWorker.perform_async
  end
end
