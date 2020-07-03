# frozen_string_literal: true

module Migrator
  module Migrations
    module Organizations
      class Domains < Base
        depends_on "organizations/organizations"

        def data
          <<~SQL
            INSERT INTO organizations_domains (id, domain, "default", organization_id, created_at, updated_at)
            SELECT
              tenants_domains.id,
              LOWER(tenants_domains.domain),
              COALESCE(tenants_domains."default", false),
              migrator_syncs.organizations_organization_id,
              tenants_domains.created_at,
              tenants_domains.updated_at
            FROM tenants_domains
            JOIN migrator_syncs ON migrator_syncs.tenants_tenant_id = tenants_domains.tenant_id
            JOIN tenants_tenants ON tenants_tenants.id = tenants_domains.tenant_id
            ON CONFLICT (id) DO NOTHING
          SQL
        end

        def count_migrated
          count("SELECT count(*) FROM organizations_domains")
        end

        def count_required
          count("SELECT count(*) FROM tenants_domains" \
                " JOIN tenants_tenants ON tenants_tenants.id = tenants_domains.tenant_id")
        end
      end
    end
  end
end
