module Migrator
  module Migrations
    module Users
      class Users < Base
        depends_on "organizations/organizations"

        def data
          <<~SQL
            INSERT INTO
              users_users (
                type,
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
              'Users::User',
              users.email,
              (array_agg(users.encrypted_password))[1],
              'active',
              (array_agg(users.current_sign_in_at))[1],
              (array_agg(users.current_sign_in_ip))[1],
              (array_agg(users.created_at))[1],
              (array_agg(users.updated_at))[1],
              (array_agg(users.deleted_at))[1]
            FROM
              users
            JOIN tenants ON tenants.id = users.tenant_id
            WHERE
              users.role_id IN (1, 3, 4)
            GROUP BY users.email
            ON CONFLICT (email, type) WHERE organization_id IS NULL
              DO NOTHING
          SQL
        end

        def sync
          <<~SQL
            INSERT INTO migrator_syncs (users_user_id, tenants_user_id, user_id)
            SELECT
              users_users.id,
              tenants_users.id,
              users.id
            FROM users
            JOIN users_users ON users_users.email = users.email AND users_users.type = 'Users::User'
            LEFT JOIN tenants ON tenants.id = users.tenant_id
            LEFT JOIN tenants_users ON tenants_users.legacy_id = users.id
            WHERE users.role_id IN (1, 3, 4)
            ON CONFLICT (users_user_id, user_id) DO NOTHING
          SQL
        end

        def count_migrated
          [
            count("SELECT COUNT(*) FROM users_users WHERE type = 'Users::User'"),
            count("SELECT COUNT(*) FROM migrator_syncs WHERE user_id IS NOT NULL AND organizations_organization_id IS NULL")
          ]
        end

        def count_required
          [
            count("SELECT COUNT(DISTINCT email) FROM users  WHERE role_id IN (1, 3, 4)"),
            count("SELECT COUNT(email) FROM users WHERE role_id IN (1, 3, 4)")
          ]
        end
      end
    end
  end
end
