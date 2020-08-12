# frozen_string_literal: true

module Migrator
  module Migrations
    module Users
      class Users < Base
        def data
          <<~SQL
            UPDATE users_users
            SET type = CASE
                        WHEN organization_id IS NOT NULL THEN 'Organizations::User'
                        WHEN organization_id IS NULL THEN 'Users::User'
                       END
            WHERE type IS NULL
          SQL
        end

        def count_required
          count("SELECT count(*) FROM users_users
                WHERE type IS NULL")
        end
      end
    end
  end
end
