module Migrator
  module Migrations
  module Organizations
      class Scopes < Base
        depends_on "organizations/organizations", "groups/groups", "users/users"

        def data
          <<~SQL
            INSERT INTO organizations_scopes (id, target_id, target_type, content, created_at, updated_at)
            SELECT
              tenants_scopes.id,
              tenants_scopes.target_id,
              CASE
                WHEN tenants_scopes.target_type = 'Tenants::Group'
                  THEN 'Groups::Group'
                WHEN tenants_scopes.target_type = 'Tenants::User'
                  THEN 'Organizations::User'
                WHEN tenants_scopes.target_type = 'Tenants::Tenant'
                  THEN 'Organizations::Organization'
              END,
              CASE
                WHEN tenants_scopes.target_type = 'Tenants::Group'
                  THEN tenants_scopes.content
                WHEN tenants_scopes.target_type = 'Tenants::User'
                  THEN tenants_scopes.content
                WHEN tenants_scopes.target_type = 'Tenants::Tenant'
                  THEN (tenants_scopes.content || jsonb_build_object('default_currency', tenants.currency))
              END,
              tenants_scopes.created_at,
              tenants_scopes.updated_at
            FROM tenants_scopes
            LEFT JOIN tenants_tenants ON tenants_tenants.id = tenants_scopes.target_id
            LEFT JOIN tenants ON tenants.id = tenants_tenants.legacy_id
            ON CONFLICT (target_id, target_type) DO NOTHING
          SQL
        end

        def count_migrated
          count("SELECT count(*) FROM organizations_scopes")
        end

        def count_required
          count("SELECT count(*) FROM tenants_scopes"\
                " LEFT JOIN tenants_tenants ON tenants_tenants.id = tenants_scopes.target_id" \
                " LEFT JOIN tenants ON tenants.id = tenants_tenants.legacy_id")
        end
      end
    end
  end
end
