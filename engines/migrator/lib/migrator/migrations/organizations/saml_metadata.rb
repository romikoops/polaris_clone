# frozen_string_literal: true

module Migrator
  module Migrations
    module Organizations
      class SamlMetadata < Base
        depends_on "organizations/organizations"

        def data
          <<~SQL
            INSERT INTO organizations_saml_metadata (id, content, organization_id, created_at, updated_at)
            SELECT
              tenants_saml_metadata.id,
              tenants_saml_metadata.content,
              migrator_syncs.organizations_organization_id,
              tenants_saml_metadata.created_at,
              tenants_saml_metadata.updated_at
            FROM tenants_saml_metadata
            JOIN migrator_syncs ON migrator_syncs.tenants_tenant_id = tenants_saml_metadata.tenant_id
            JOIN tenants_tenants ON tenants_tenants.id = tenants_saml_metadata.tenant_id
            ON CONFLICT (id) DO NOTHING
          SQL
        end

        def count_migrated
          count("SELECT count(*) FROM organizations_saml_metadata")
        end

        def count_required
          count("SELECT count(*) FROM tenants_saml_metadata" \
                " JOIN tenants_tenants ON tenants_tenants.id = tenants_saml_metadata.tenant_id")
        end
      end
    end
  end
end
