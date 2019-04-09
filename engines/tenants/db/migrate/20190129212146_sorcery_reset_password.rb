# frozen_string_literal: true

class SorceryResetPassword < ActiveRecord::Migration[5.2]
  def change
    add_column :tenants_users, :reset_password_token, :string, default: nil
    add_column :tenants_users, :reset_password_token_expires_at, :datetime, default: nil
    add_column :tenants_users, :reset_password_email_sent_at, :datetime, default: nil
    add_column :tenants_users, :access_count_to_reset_password_page, :integer, default: nil
    change_column_default :tenants_users, :access_count_to_reset_password_page, 0
  end
end
