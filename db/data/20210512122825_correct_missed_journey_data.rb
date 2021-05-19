# frozen_string_literal: true

class CorrectMissedJourneyData < ActiveRecord::Migration[5.2]
  def up
    CorrectMissedJourneyDataWorker.perform_async
  end
end
