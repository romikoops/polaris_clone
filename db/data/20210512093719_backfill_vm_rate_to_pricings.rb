class BackfillVmRateToPricings < ActiveRecord::Migration[5.2]
  def up
    BackfillVmRateToPricingsWorker.perform_async
  end
end
