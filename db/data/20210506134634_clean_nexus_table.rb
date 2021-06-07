# frozen_string_literal: true

class CleanNexusTable < ActiveRecord::Migration[5.2]
  def up
    CleanNexusTableWorker.perform_async
  end
end
