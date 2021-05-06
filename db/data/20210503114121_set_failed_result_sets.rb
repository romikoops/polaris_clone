# frozen_string_literal: true

class SetFailedResultSets < ActiveRecord::Migration[5.2]
  def up
    SetFailedResultSetsWorker.perform_async
  end
end
