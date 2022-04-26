# frozen_string_literal: true

class AddIntegrationKeyToWwa < ActiveRecord::Migration[5.2]
  def up
    AddIntegrationKeyToWwaWorker.perform_async
  end
end
