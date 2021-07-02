# frozen_string_literal: true

class CorrectUpsertIds < ActiveRecord::Migration[5.2]
  def up
    CorrectUpsertIdsWorker.perform_async
  end
end
