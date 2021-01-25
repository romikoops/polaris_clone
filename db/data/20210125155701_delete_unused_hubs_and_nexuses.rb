class DeleteUnusedHubsAndNexuses < ActiveRecord::Migration[5.2]
  def up
    DeleteUnusedHubsAndNexusesWorker.perform_async
  end
end
