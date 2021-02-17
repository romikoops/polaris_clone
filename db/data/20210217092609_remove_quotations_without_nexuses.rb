class RemoveQuotationsWithoutNexuses < ActiveRecord::Migration[5.2]
  def up
    RemoveQuotationsWithoutNexusesWorker.perform_async
  end
end
