# frozen_string_literal: true

module Migrator
  module Migrations
    module Companies
      module Memberships
        class Deleted < Base
          def data
            <<~SQL
              UPDATE companies_memberships
              SET deleted_at = clock_timestamp()
              FROM users_users
              WHERE companies_memberships.member_type = 'Users::User'
              AND companies_memberships.member_id = users_users.id
              AND users_users.deleted_at IS NOT NULL
            SQL
          end

          def count_required
            count("
                SELECT COUNT(*)
                FROM companies_memberships AS cm
                JOIN users_users ON cm.member_id = users_users.id
                WHERE cm.member_type = 'Users::User'
                AND users_users.deleted_at IS NOT NULL
            ")
          end
        end
      end
    end
  end
end
