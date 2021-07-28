# frozen_string_literal: true

class BackfillTerminalsOnHubs < ActiveRecord::Migration[5.2]
  def up
    BackfillTerminalsOnHubsWorker.perform_async
  end
end
