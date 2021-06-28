# frozen_string_literal: true

class BackfillUpsertIdOnItinerary < ActiveRecord::Migration[5.2]
  def up
    BackfillUpsertIdOnItineraryWorker.perform_async
  end
end
