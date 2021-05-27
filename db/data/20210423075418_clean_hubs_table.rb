# frozen_string_literal: true

class CleanHubsTable < ActiveRecord::Migration[5.2]
  def up
    CleanHubsTableWorker.perform_async
  end
end
