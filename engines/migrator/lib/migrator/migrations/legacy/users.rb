# frozen_string_literal: true

module Migrator
  module Migrations
    module Legacy
      class Users < Base
        depends_on "organizations/organizations", "organizations/users", "users/users"

        def data
          @statements ||= begin
            statements = []

            tables
              .collect { |table| [table, columns(table).find { |col| col.name == "legacy_user_id" }] }
              .each do |(table, column)|
              next unless column

              case column.type
              when :uuid
                statements << <<~SQL
                  UPDATE #{table}
                    SET user_id = migrator_syncs.users_user_id
                  FROM migrator_syncs
                    WHERE migrator_syncs.tenants_user_id = #{table}.legacy_user_id
                    AND #{table}.user_id IS NULL AND legacy_user_id IS NOT NULL
                SQL
              when :integer
                statements << <<~SQL
                  UPDATE #{table}
                    SET user_id = migrator_syncs.users_user_id
                  FROM migrator_syncs
                    WHERE migrator_syncs.user_id = #{table}.legacy_user_id
                    AND #{table}.user_id IS NULL AND legacy_user_id IS NOT NULL
                SQL
              end
            end

            statements
          end
        end
      end
    end
  end
end
