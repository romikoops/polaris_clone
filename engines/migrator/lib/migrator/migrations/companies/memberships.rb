module Migrator
  module Migrations
    module Companies
      class Memberships < Base
        depends_on "companies/companies", "organizations/users", "users/users"

        def data
          <<~SQL
            INSERT INTO companies_memberships (member_id, member_type, company_id, created_at, updated_at)
            SELECT
              migrator_syncs.users_user_id,
              'Users::User',
              tenants_users.company_id,
              now(),
              now()
            FROM tenants_users
            JOIN migrator_syncs ON tenants_users.id = migrator_syncs.tenants_user_id
            WHERE tenants_users.company_id IS NOT NULL
            ON CONFLICT (company_id, member_id) DO NOTHING
          SQL
        end

        def count_migrated
          count("SELECT count(*) FROM companies_memberships")
        end

        def count_required
          count("SELECT count(*) FROM tenants_users WHERE tenants_users.company_id IS NOT NULL")
        end
      end
    end
  end
end
