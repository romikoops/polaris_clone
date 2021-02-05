class SubscribeOrgsToOfferCreated < ActiveRecord::Migration[5.2]
  def up
    SubscribeOrgsToOfferCreatedWorker.perform_async
  end
end
