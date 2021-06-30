# frozen_string_literal: true

class DedupeHubFromInserterError < ActiveRecord::Migration[5.2]
  def up
    DedupeHubFromInserterErrorWorker.perform_async
  end
end
