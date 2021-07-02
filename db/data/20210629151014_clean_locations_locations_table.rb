# frozen_string_literal: true

class CleanLocationsLocationsTable < ActiveRecord::Migration[5.2]
  def up
    CleanLocationsLocationsTableWorker.perform_async
  end
end
