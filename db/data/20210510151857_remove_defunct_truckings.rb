# frozen_string_literal: true

class RemoveDefunctTruckings < ActiveRecord::Migration[5.2]
  def up
    RemoveDefunctTruckingsWorker.perform_async
  end
end
