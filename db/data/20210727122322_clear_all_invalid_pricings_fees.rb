# frozen_string_literal: true

class ClearAllInvalidPricingsFees < ActiveRecord::Migration[5.2]
  def up
    ClearAllInvalidPricingsFeesWorker.perform_async
  end
end
