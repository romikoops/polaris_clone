# frozen_string_literal: true

class BackkfillDeletedAtForOutdatedNotes < ActiveRecord::Migration[5.2]
  def up
    Legacy::BackkfillDeletedAtForOutdatedNotesWorker.perform_async
  end
end
