# frozen_string_literal: true

module Migrator
  module Migrations
    module Profiles
      class Profiles < Base
        depends_on "users/users", "organizations/users"

        def data
          <<~SQL
            UPDATE
                profiles_profiles
              SET user_id = migrator_syncs.users_user_id
              FROM migrator_syncs
              WHERE migrator_syncs.tenants_user_id IS NOT NULL
                AND migrator_syncs.tenants_user_id = profiles_profiles.legacy_user_id
          SQL
        end

        def count_migrated
          count <<~SQL
            SELECT COUNT(*) FROM profiles_profiles WHERE user_id IN (SELECT users_user_id FROM migrator_syncs)
          SQL
        end

        def count_required
          count <<~SQL
            SELECT COUNT(*) FROM migrator_syncs WHERE migrator_syncs.tenants_user_id IS NOT NULL
          SQL
        end
      end
    end
  end
end
