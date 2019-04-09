# frozen_string_literal: true

class UsersUsersActivityLogging < ActiveRecord::Migration[5.2]
  def change
    add_column :users_users, :last_login_at,     :datetime, default: nil
    add_column :users_users, :last_logout_at,    :datetime, default: nil
    add_column :users_users, :last_activity_at,  :datetime, default: nil
    add_column :users_users, :last_login_from_ip_address, :string, default: nil
  end
end
