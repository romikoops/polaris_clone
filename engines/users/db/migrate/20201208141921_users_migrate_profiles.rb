# frozen_string_literal: true
class UsersMigrateProfiles < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute <<-SQL
        INSERT INTO users_client_profiles (
            id,
            first_name,
            last_name,
            company_name,
            phone,
            deleted_at,
            external_id,
            user_id,
            created_at,
            updated_at
        )
        (
          SELECT DISTINCT ON (users_profiles.user_id)
                 users_profiles.id,
                 users_profiles.first_name,
                 users_profiles.last_name,
                 users_profiles.company_name,
                 users_profiles.phone,
                 users_profiles.deleted_at,
                 users_profiles.external_id,
                 users_profiles.user_id,
                 users_profiles.created_at,
                 users_profiles.updated_at
          FROM users_profiles
          LEFT JOIN users_users ON users_users.id = users_profiles.user_id
          WHERE users_users.type = 'Organizations::User'
          AND users_profiles.deleted_at IS NULL
        )
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end
end
