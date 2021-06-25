# frozen_string_literal: true

class ProperlyDedupeItineraries < ActiveRecord::Migration[5.2]
  def up
    ProperlyDedupeItinerariesWorker.perform_async
  end
end
