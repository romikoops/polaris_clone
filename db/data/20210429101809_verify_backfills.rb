# frozen_string_literal: true

class VerifyBackfills < ActiveRecord::Migration[5.2]
  def up
    VerifyBackfillsWorker.perform_async
  end
end
