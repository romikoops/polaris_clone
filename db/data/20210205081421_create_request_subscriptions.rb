class CreateRequestSubscriptions < ActiveRecord::Migration[5.2]
  def up
    CreateRequestSubscriptionsWorker.perform_async
  end
end
