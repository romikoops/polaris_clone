# frozen_string_literal: true

module Migrator
  module Migrations
    module Organizations
      class Memberships < Base
        depends_on "organizations/organizations", "users/users"

        def data
          <<~SQL
            INSERT INTO organizations_memberships (user_id, organization_id, role, created_at, updated_at)
            SELECT
              u.users_user_id,
              t.organizations_organization_id,
              #{::Organizations::Membership.roles[:admin]},
              now(),
              now()
            FROM
              users
            JOIN migrator_syncs u ON u.user_id = users.id
            JOIN migrator_syncs t ON t.tenant_id = users.tenant_id
            LEFT JOIN tenants ON tenants.id = users.tenant_id
            WHERE
              users.role_id IN (1, 3, 4)
            ON CONFLICT (user_id, organization_id) DO NOTHING
          SQL
        end

        def count_migrated
          count("SELECT count(*) FROM organizations_memberships")
        end

        def count_required
          count("SELECT COUNT(users.id) FROM users LEFT JOIN tenants ON tenants.id = users.tenant_id" \
                  " WHERE role_id IN (1, 3, 4)")
        end
      end
    end
  end
end
