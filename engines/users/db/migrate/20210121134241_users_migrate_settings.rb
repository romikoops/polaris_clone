# frozen_string_literal: true
class UsersMigrateSettings < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute <<-SQL
        INSERT INTO users_client_settings (
            id,
            locale,
            language,
            currency,
            user_id,
            created_at,
            updated_at
        )
        (
          SELECT DISTINCT ON (users_settings.user_id)
                 users_settings.id,
                 users_settings.locale,
                 users_settings.language,
                 users_settings.currency,
                 users_settings.user_id,
                 users_settings.created_at,
                 users_settings.updated_at
          FROM users_settings
          LEFT JOIN users_users ON users_users.id = users_settings.user_id
          WHERE users_users.type = 'Organizations::User'
          AND users_settings.deleted_at IS NULL
        )
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end
end
