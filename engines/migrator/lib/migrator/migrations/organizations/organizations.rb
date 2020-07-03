# frozen_string_literal: true

module Migrator
  module Migrations
    module Organizations
      class Organizations < Base
        def data
          <<-EOF
            INSERT INTO organizations_organizations (id, slug, created_at, updated_at)
            SELECT
              tenants_tenants.id,
              tenants_tenants.slug,
              tenants.created_at,
              tenants.updated_at
            FROM tenants
            JOIN tenants_tenants ON tenants_tenants.legacy_id = tenants.id
            ON CONFLICT (id) DO NOTHING
          EOF
        end

        def sync
          <<~SQL
            INSERT INTO migrator_syncs (organizations_organization_id, tenants_tenant_id, tenant_id)
            SELECT
              organizations_organizations.id,
              tenants_tenants.id,
              tenants_tenants.legacy_id
            FROM organizations_organizations
            JOIN tenants_tenants ON organizations_organizations.id = tenants_tenants.id
            ON CONFLICT (organizations_organization_id, tenant_id) DO NOTHING
          SQL
        end

        def count_migrated
          [
            count("SELECT COUNT(*) FROM tenants"),
            count("SELECT COUNT(*) FROM migrator_syncs WHERE tenant_id IS NOT NULL")
          ]
        end

        def count_required
          [
            count("SELECT COUNT(*) FROM organizations_organizations"),
            count("SELECT COUNT(*) FROM tenants")
          ]
        end
      end
    end
  end
end
