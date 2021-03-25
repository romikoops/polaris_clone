class BackfillJourneyModels < ActiveRecord::Migration[5.2]
  def up
    BackfillJourneyModelsWorker.perform_async
  end
end
