# frozen_string_literal: true

module Migrator
  module Migrations
    module Groups
      class Memberships < Base
        depends_on "companies/companies", "groups/groups", "organizations/users", "users/users"

        def data
          [migrate_groups_companies_memberships, migrate_users]
        end

        def migrate_groups_companies_memberships
          <<~SQL
            INSERT INTO groups_memberships (id, member_id, member_type, group_id, priority, created_at, updated_at)
            SELECT
              tenants_memberships.id,
              tenants_memberships.member_id,
              CASE
                WHEN tenants_memberships.member_type = 'Tenants::Group'   THEN 'Groups::Group'
                WHEN tenants_memberships.member_type = 'Tenants::Company' THEN 'Companies::Company'
              END,
              tenants_memberships.group_id,
              tenants_memberships.priority,
              tenants_memberships.created_at,
              tenants_memberships.updated_at
            FROM tenants_memberships
            LEFT JOIN tenants_groups ON tenants_groups.id = tenants_memberships.group_id
            WHERE tenants_groups.id IS NOT NULL
            AND tenants_memberships.member_type IN ('Tenants::Group', 'Tenants::Company')
            ON CONFLICT (id) DO NOTHING;
          SQL
        end

        def migrate_users
          <<~SQL
            INSERT INTO groups_memberships (id, member_id, member_type, group_id, priority, created_at, updated_at)
            SELECT
              tenants_memberships.id,
              migrator_syncs.users_user_id,
              'Users::User',
              tenants_memberships.group_id,
              tenants_memberships.priority,
              tenants_memberships.created_at,
              tenants_memberships.updated_at
            FROM tenants_memberships
            LEFT JOIN tenants_groups ON tenants_groups.id = tenants_memberships.group_id
            JOIN migrator_syncs ON migrator_syncs.tenants_user_id = tenants_memberships.member_id
            WHERE tenants_groups.id IS NOT NULL
            AND tenants_memberships.member_type = 'Tenants::User'
            ON CONFLICT (id) DO NOTHING
          SQL
        end

        def count_migrated
          [count_groups_companies_migrated, count_users_migrated]
        end

        def count_required
          [count_groups_companies_required, count_users_required]
        end

        def count_groups_companies_migrated
          count("SELECT count(*) FROM groups_memberships" \
                " WHERE groups_memberships.member_type IN ('Groups::Group', 'Companies::Company')")
        end

        def count_users_migrated
          count("SELECT count(*) FROM groups_memberships WHERE groups_memberships.member_type = 'Users::User'")
        end

        def count_groups_companies_required
          count("SELECT count(*) FROM tenants_memberships" \
                " LEFT JOIN tenants_groups ON tenants_groups.id = tenants_memberships.group_id" \
                " WHERE tenants_groups.id IS NOT NULL" \
                " AND tenants_memberships.member_type IN ('Tenants::Group', 'Tenants::Company')")
        end

        def count_users_required
          count("SELECT count(*) FROM tenants_memberships" \
                " LEFT JOIN tenants_groups ON tenants_groups.id = tenants_memberships.group_id" \
                " JOIN migrator_syncs ON migrator_syncs.tenants_user_id = tenants_memberships.member_id" \
                " WHERE tenants_groups.id IS NOT NULL AND tenants_memberships.member_type = 'Tenants::User'")
        end
      end
    end
  end
end
