# frozen_string_literal: true

class SorceryBruteForceProtection < ActiveRecord::Migration[5.2]
  def change
    add_column :tenants_users, :failed_logins_count, :integer, default: nil
    add_column :tenants_users, :lock_expires_at, :datetime, default: nil
    add_column :tenants_users, :unlock_token, :string, default: nil
    change_column_default :tenants_users, :failed_logins_count, 0
  end
end
