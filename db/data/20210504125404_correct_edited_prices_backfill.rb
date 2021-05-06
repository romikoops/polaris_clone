# frozen_string_literal: true

class CorrectEditedPricesBackfill < ActiveRecord::Migration[5.2]
  def up
    CorrectEditedPricesBackfillWorker.perform_async
  end
end
