# frozen_string_literal: true

class RedupeRoutePoints < ActiveRecord::Migration[5.2]
  def up
    RedupeRoutePointsWorker.perform_async
  end
end
