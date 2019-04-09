# frozen_string_literal: true

class SorceryIndexes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :tenants_users, :activation_token, algorithm: :concurrently
    add_index :tenants_users, :reset_password_token, algorithm: :concurrently
    add_index :tenants_users, :unlock_token, algorithm: :concurrently
    add_index :tenants_users, %i(last_logout_at last_activity_at), algorithm: :concurrently

    add_index :tenants_users, %i(email tenant_id), unique: true, algorithm: :concurrently
  end
end
