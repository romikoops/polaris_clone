# frozen_string_literal: true

class BackfillQueryIdToResult < ActiveRecord::Migration[5.2]
  def up
    BackfillQueryIdToResultWorker.perform_async
  end
end
