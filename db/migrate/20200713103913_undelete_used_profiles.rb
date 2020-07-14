class UndeleteUsedProfiles < ActiveRecord::Migration[5.2]
  def up
    exec_update <<-SQL
      UPDATE profiles_profiles
      SET deleted_at = null
      FROM users_users
      WHERE users_users.id = profiles_profiles.user_id
      AND users_users.deleted_at IS NULL
      AND profiles_profiles.deleted_at IS NOT NULL;
    SQL
  end

  def down
  end
end
