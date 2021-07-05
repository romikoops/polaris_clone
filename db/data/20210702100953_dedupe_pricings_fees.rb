class DedupePricingsFees < ActiveRecord::Migration[5.2]
  def up
    DedupePricingsFeesWorker.perform_async
  end
end
