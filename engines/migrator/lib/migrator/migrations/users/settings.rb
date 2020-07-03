module Migrator
  module Migrations
    module Users
      class Settings < Base
        depends_on "users/users"

        def data
          <<~SQL
            INSERT INTO users_settings (user_id, currency, created_at, updated_at)
            SELECT
              migrator_syncs.users_user_id,
              users.currency,
              now(),
              now()
            FROM
              users_users
            JOIN migrator_syncs ON migrator_syncs.users_user_id = users_users.id
            JOIN users ON users.id = migrator_syncs.user_id
            ON CONFLICT (user_id) DO NOTHING
          SQL
        end

        def count_migrated
          count("SELECT count(*) FROM users_settings")
        end

        def count_required
          count("SELECT count(*) FROM users_users")
        end
      end
    end
  end
end
