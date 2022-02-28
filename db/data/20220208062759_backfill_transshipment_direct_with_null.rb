# frozen_string_literal: true

class BackfillTransshipmentDirectWithNull < ActiveRecord::Migration[5.2]
  def up
    BackfillTransshipmentDirectWithItineraryDedupWorker.perform_async
    BackfillTransshipmentDirectWithNullWorker.perform_async
  end
end
