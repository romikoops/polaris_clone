# frozen_string_literal: true

class SetEmptyTendersAsFailed < ActiveRecord::Migration[5.2]
  def up
    SetEmptyTendersAsFailedWorker.perform_async
  end
end
