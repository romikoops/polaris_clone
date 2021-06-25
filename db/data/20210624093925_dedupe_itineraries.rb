# frozen_string_literal: true

class DedupeItineraries < ActiveRecord::Migration[5.2]
  def up
    DedupeItinerariesWorker.perform_async
  end
end
