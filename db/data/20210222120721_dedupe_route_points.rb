# frozen_string_literal: true

class DedupeRoutePoints < ActiveRecord::Migration[5.2]
  def up
    DedupeRoutePointsWorker.perform_async
  end
end
