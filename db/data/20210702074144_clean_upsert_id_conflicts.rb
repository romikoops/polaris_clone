# frozen_string_literal: true

class CleanUpsertIdConflicts < ActiveRecord::Migration[5.2]
  def up
    CleanUpsertIdConflictsWorker.perform_async
  end
end
