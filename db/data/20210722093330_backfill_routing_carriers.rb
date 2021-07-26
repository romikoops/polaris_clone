# frozen_string_literal: true

class BackfillRoutingCarriers < ActiveRecord::Migration[5.2]
  def up
    BackfillRoutingCarriersWorker.perform_async
  end
end
