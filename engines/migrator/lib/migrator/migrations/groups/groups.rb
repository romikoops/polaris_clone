# frozen_string_literal: true

module Migrator
  module Migrations
    module Groups
      class Groups < Base
        depends_on "organizations/organizations"

        def data
          <<~SQL
            INSERT INTO groups_groups (id, name, organization_id, created_at, updated_at)
            SELECT
              tenants_groups.id,
              tenants_groups.name,
              migrator_syncs.organizations_organization_id,
              tenants_groups.created_at,
              tenants_groups.updated_at
            FROM tenants_groups
            JOIN migrator_syncs ON migrator_syncs.tenants_tenant_id = tenants_groups.tenant_id
            ON CONFLICT (id) DO NOTHING
          SQL
        end

        def count_migrated
          count("SELECT count(*) FROM groups_groups")
        end

        def count_required
          count("SELECT count(*) FROM tenants_groups")
        end
      end
    end
  end
end
