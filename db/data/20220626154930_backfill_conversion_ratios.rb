# frozen_string_literal: true

class BackfillConversionRatios < ActiveRecord::Migration[5.2]
  def up
    BackfillConversionRatiosWorker.perform_async
  end
end
