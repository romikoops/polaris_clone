# frozen_string_literal: true

class DeduplicateTruckingLocationAgain < ActiveRecord::Migration[5.2]
  def up
    DeduplicateTruckingLocationAgainWorker.perform_async
  end
end
