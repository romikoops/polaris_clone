# frozen_string_literal: true

module Migrator
  module Migrations
    module Legacy
      class Tenants < Base
        depends_on "organizations/organizations"

        BLACKLIST_TABLES = %w[
          organizations_domains
          organizations_memberships
          organizations_organizations
          organizations_saml_metadata
          organizations_scopes
          organizations_themes

          tenants_companies
          tenants_domains
          tenants_groups
          tenants_saml_metadata
          tenants_sandboxes
          tenants_themes
          tenants_users
        ]

        def data
          @statements ||= begin
            statements = []

            migrator_map = migrator
              .execute("SELECT organizations_organization_id, tenant_id FROM migrator_syncs WHERE tenant_id IS NOT NULL")
              .values

            tables
              .collect { |table| [table, columns(table).find { |col| col.name == "tenant_id" }] }
              .each do |(table, column)|
              next unless column
              next if BLACKLIST_TABLES.include?(table)

              case column.type
              when :uuid
                statements << "UPDATE #{table} SET organization_id = tenant_id WHERE organization_id IS NULL"
              when :integer
                migrator_map.each do |(organization_id, tenant_id)|
                  statements << <<~SQL
                    UPDATE #{table}
                      SET organization_id = '#{organization_id}'
                    WHERE tenant_id = #{tenant_id}
                      AND organization_id IS NULL AND tenant_id IS NOT NULL
                  SQL
                end
              end
            end

            statements
          end
        end
      end
    end
  end
end
