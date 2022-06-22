# frozen_string_literal: true

class RepublishMissedEvents < ActiveRecord::Migration[5.2]
  def up
    RepublishMissedEventsWorker.perform_async
  end
end
