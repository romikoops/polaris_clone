# frozen_string_literal: true

class RemoveDefunctTruckingsWorker
  include Sidekiq::Worker

  def perform
    ActiveRecord::Base.connection.execute("
      UPDATE trucking_truckings
      SET deleted_at = clock_timestamp()
      WHERE location_id NOT IN (
        SELECT id FROM trucking_locations
        WHERE deleted_at IS NULL
      )
    ")
  end
end
