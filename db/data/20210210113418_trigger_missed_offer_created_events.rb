class TriggerMissedOfferCreatedEvents < ActiveRecord::Migration[5.2]
  def up
    TriggerMissedOfferCreatedEventsWorker.perform_async
  end
end
