# frozen_string_literal: true

class BackfillUpsertIdOnPricingsAndFees < ActiveRecord::Migration[5.2]
  def up
    BackfillUpsertIdOnPricingsAndFeesWorker.perform_async
  end
end
