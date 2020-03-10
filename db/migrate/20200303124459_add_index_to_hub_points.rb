# frozen_string_literal: true

class AddIndexToHubPoints < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :hubs, :point, using: :gist, algorithm: :concurrently
  end
end
