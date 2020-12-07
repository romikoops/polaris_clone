class AdminEmailToSubscription < ActiveRecord::Migration[5.2]
  def up
    Notifications::MigrateAdminSubscriptionsWorker.perform_async
  end
end
