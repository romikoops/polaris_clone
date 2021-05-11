# frozen_string_literal: true

class BackfillChargeableDensity < ActiveRecord::Migration[5.2]
  def up
    BackfillChargeableDensityWorker.perform_async
  end
end
