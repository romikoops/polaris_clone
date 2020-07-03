# frozen_string_literal: true

module Migrator
  module Migrations
    module Organizations
      class Users < Base
        depends_on "organizations/organizations"

        def data
          <<~SQL
            INSERT INTO
              users_users (
                type,
                organization_id,
                email,
                crypted_password,
                activation_state,
                last_login_at,
                last_login_from_ip_address,
                created_at,
                updated_at,
                deleted_at
              )
            SELECT
              'Organizations::User',
              migrator_syncs.organizations_organization_id,
              users.email,
              users.encrypted_password,
              'active',
              users.current_sign_in_at,
              users.current_sign_in_ip,
              users.created_at,
              users.updated_at,
              users.deleted_at
            FROM
              users
            JOIN tenants ON tenants.id = users.tenant_id
            LEFT JOIN migrator_syncs ON migrator_syncs.tenant_id = users.tenant_id
            WHERE
              (users.guest IS false OR users.guest IS NULL)
              AND users.role_id IN (2, 5, 6)
            ON CONFLICT (email, organization_id) DO NOTHING
          SQL
        end

        def sync
          <<~SQL
            INSERT INTO migrator_syncs (users_user_id, tenants_user_id, user_id, organizations_organization_id)
            SELECT
              users_users.id,
              tenants_users.id,
              users.id,
              migrator_syncs.organizations_organization_id
            FROM users
            JOIN users_users ON users_users.email = users.email
              AND users_users.type = 'Organizations::User'
            JOIN migrator_syncs ON migrator_syncs.tenant_id = users.tenant_id
              AND migrator_syncs.organizations_organization_id = users_users.organization_id
            LEFT JOIN tenants ON tenants.id = users.tenant_id
            LEFT JOIN tenants_users ON tenants_users.legacy_id = users.id
            WHERE
              (users.guest IS false OR users.guest IS NULL)
              AND users.role_id IN (2, 5, 6)
            ON CONFLICT (users_user_id, user_id) DO NOTHING
          SQL
        end

        def count_migrated
          [
            count("SELECT count(*) FROM users_users WHERE type = 'Organizations::User'"),
            # count("SELECT COUNT(*) FROM migrator_syncs WHERE user_id IS NOT NULL AND organizations_organization_id IS NOT NULL")
          ]
        end

        def count_required
          [
            count("SELECT COUNT(email) FROM users LEFT JOIN tenants ON tenants.id = users.tenant_id" \
                  " WHERE (users.guest IS false OR users.guest IS NULL) AND role_id IN (2, 5, 6)"),
            # count("SELECT COUNT(email) FROM users WHERE (users.guest IS false OR users.guest IS NULL)" \
            #       " AND role_id IN (2, 5, 6)")
          ]
        end
      end
    end
  end
end
