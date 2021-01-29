class UsersMigrateClients < ActiveRecord::Migration[5.2]
  # Allow 3 minutes migration
  set_statement_timeout(3 * 60 * 1000)

  def up
    safety_assured do
      migrate_clients
    end
  end

  def migrate_clients
    execute <<-SQL
      INSERT INTO users_clients (
        id,
        organization_id,
        deleted_at,
        email,
        crypted_password,
        salt,
        last_login_at,
        last_logout_at,
        last_activity_at,
        last_login_from_ip_address,
        unlock_token,
        failed_logins_count,
        lock_expires_at,
        magic_login_token,
        magic_login_token_expires_at,
        magic_login_email_sent_at,
        reset_password_token,
        reset_password_token_expires_at,
        reset_password_email_sent_at,
        access_count_to_reset_password_page,
        activation_token,
        activation_state,
        activation_token_expires_at,
        created_at,
        updated_at
      )
        (SELECT id,
                organization_id,
                deleted_at,
                email,
                crypted_password,
                salt,
                last_login_at,
                last_logout_at,
                last_activity_at,
                last_login_from_ip_address,
                unlock_token,
                failed_logins_count,
                lock_expires_at,
                magic_login_token,
                magic_login_token_expires_at,
                magic_login_email_sent_at,
                reset_password_token,
                reset_password_token_expires_at,
                reset_password_email_sent_at,
                access_count_to_reset_password_page,
                activation_token,
                activation_state,
                activation_token_expires_at,
                created_at,
                updated_at
          FROM users_users WHERE type = 'Organizations::User')
      ON CONFLICT (id) DO NOTHING
    SQL
  end
end
