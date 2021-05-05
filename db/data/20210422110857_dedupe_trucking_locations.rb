# frozen_string_literal: true

class DedupeTruckingLocations < ActiveRecord::Migration[5.2]
  def up
    DedupeTruckingLocationsWorker.perform_async
  end
end
