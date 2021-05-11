# frozen_string_literal: true

class BackfillChargeableDensityWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    ActiveRecord::Migration.exec_update(
      <<-SQL
      UPDATE journey_line_items
      SET chargeable_density = wm_rate;
      SQL
    )
  end
end
