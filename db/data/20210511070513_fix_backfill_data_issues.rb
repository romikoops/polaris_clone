# frozen_string_literal: true

class FixBackfillDataIssues < ActiveRecord::Migration[5.2]
  def up
    FixBackfillDataIssuesWorker.perform_async
  end
end
