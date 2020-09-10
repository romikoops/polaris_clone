# frozen_string_literal: true

module Migrator
  module Migrations
    module Groups
      class Memberships < Base
        def data
          delete_memberships
        end

        def delete_memberships
          <<-SQL
            UPDATE groups_memberships
            SET deleted_at = now()
            WHERE groups_memberships.id IN (
              SELECT groups_memberships.id FROM groups_memberships
              INNER JOIN users_users ON users_users.id = groups_memberships.member_id
              WHERE groups_memberships.member_type = 'Users::User'
              AND users_users.deleted_at IS NOT NULL
            )
          SQL
        end

        def count_required
          count(
            <<-SQL
              SELECT COUNT(*) FROM groups_memberships
              INNER JOIN users_users ON users_users.id = groups_memberships.member_id
              WHERE groups_memberships.member_type = 'Users::User'
              AND users_users.deleted_at IS NOT NULL
            SQL
          )
        end
      end
    end
  end
end
