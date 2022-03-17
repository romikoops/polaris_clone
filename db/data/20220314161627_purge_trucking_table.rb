# frozen_string_literal: true

class PurgeTruckingTable < ActiveRecord::Migration[5.2]
  def up
    PurgeTruckingTableWorker.perform_async
  end
end
