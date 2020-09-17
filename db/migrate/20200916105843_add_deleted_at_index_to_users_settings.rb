# frozen_string_literal: true

class AddDeletedAtIndexToUsersSettings < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :users_settings, :deleted_at, algorithm: :concurrently
  end
end
