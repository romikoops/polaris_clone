class BackfillLoadTypeOnJourneyQueries < ActiveRecord::Migration[5.2]
  def up
    BackfillLoadTypeOnJourneyQueriesWorker.perform_async
  end
end
