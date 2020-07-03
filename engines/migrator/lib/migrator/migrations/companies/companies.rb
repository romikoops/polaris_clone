# frozen_string_literal: true

module Migrator
  module Migrations
    module Companies
      class Companies < Base
        depends_on "organizations/organizations"

        def data
          <<~SQL
            INSERT INTO companies_companies (
              id, organization_id, name, email, phone, vat_number, address_id, created_at, updated_at, deleted_at
            )
            SELECT
              tenants_companies.id,
              migrator_syncs.organizations_organization_id,
              tenants_companies.name,
              tenants_companies.email,
              tenants_companies.phone,
              tenants_companies.vat_number,
              tenants_companies.address_id,
              tenants_companies.created_at,
              tenants_companies.updated_at,
              tenants_companies.deleted_at
            FROM tenants_companies
            JOIN migrator_syncs ON migrator_syncs.tenants_tenant_id = tenants_companies.tenant_id
            ON CONFLICT (id) DO NOTHING
          SQL
        end

        def count_migrated
          count("SELECT count(*) FROM companies_companies")
        end

        def count_required
          count("SELECT count(*) FROM tenants_companies")
        end
      end
    end
  end
end
