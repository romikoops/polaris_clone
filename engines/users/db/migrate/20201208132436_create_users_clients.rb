class CreateUsersClients < ActiveRecord::Migration[5.2]
  def change
    create_table :users_clients, id: :uuid do |t|
      # Oraganization Support
      t.uuid :organization_id, index: true

      # Paranoia
      t.datetime :deleted_at, default: nil

      # Core
      t.string :email, null: false, index: {where: "deleted_at IS NULL"}
      t.string :crypted_password
      t.string :salt

      # Activity Logging
      t.datetime :last_login_at, default: nil
      t.datetime :last_logout_at, default: nil
      t.datetime :last_activity_at, default: nil
      t.string :last_login_from_ip_address, default: nil

      # Brute Force
      t.string :unlock_token, default: nil, index: {where: "deleted_at IS NULL"}
      t.integer :failed_logins_count, default: 0
      t.datetime :lock_expires_at, default: nil

      # Magic Login
      t.string :magic_login_token, default: nil, index: {where: "deleted_at IS NULL"}
      t.datetime :magic_login_token_expires_at, default: nil
      t.datetime :magic_login_email_sent_at, default: nil

      # Reset Password
      t.string :reset_password_token, default: nil, index: {where: "deleted_at IS NULL"}
      t.datetime :reset_password_token_expires_at, default: nil
      t.datetime :reset_password_email_sent_at, default: nil
      t.integer :access_count_to_reset_password_page, default: 0

      # User Activation
      t.string :activation_token, default: nil, index: {where: "deleted_at IS NULL"}
      t.string :activation_state, default: nil
      t.datetime :activation_token_expires_at, default: nil

      t.timestamps null: false

      t.index %i[last_logout_at last_activity_at], name: :users_clients_activity, where: "deleted_at IS NULL"

      t.index %i[email organization_id], unique: true
    end
  end
end
