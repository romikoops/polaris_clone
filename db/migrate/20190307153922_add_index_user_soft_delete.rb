# frozen_string_literal: true

class AddIndexUserSoftDelete < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :users, :deleted_at, algorithm: :concurrently
    add_index :user_addresses, :deleted_at, algorithm: :concurrently
  end
end
