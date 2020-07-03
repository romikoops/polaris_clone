# frozen_string_literal: true

module Migrator
  module Migrations
    module Organizations
      class Themes < Base
        depends_on "organizations/organizations"

        def data
          [data_themes, data_attachments]
        end

        def count_migrated
          count("SELECT count(*) FROM organizations_themes")
        end

        def count_required
          count("SELECT count(*) FROM tenants_themes" \
                " JOIN migrator_syncs ON migrator_syncs.tenants_tenant_id = tenants_themes.tenant_id" \
                " JOIN tenants ON tenants.id = migrator_syncs.tenant_id")
        end

        private

        def data_themes
          <<~SQL
            INSERT INTO organizations_themes (
              id,
              organization_id,
              name,
              welcome_text,
              emails,
              phones,
              addresses,
              email_links,
              primary_color,
              secondary_color,
              bright_primary_color,
              bright_secondary_color,
              created_at,
              updated_at
            )
            SELECT
              tenants_themes.id,
              migrator_syncs.organizations_organization_id,
              tenants.name,
              tenants_themes.welcome_text,
              tenants.emails,
              tenants.phones,
              tenants.addresses,
              tenants.email_links,
              tenants_themes.primary_color,
              tenants_themes.secondary_color,
              tenants_themes.bright_primary_color,
              tenants_themes.bright_secondary_color,
              tenants_themes.created_at,
              tenants_themes.updated_at
            FROM tenants_themes
            JOIN migrator_syncs ON migrator_syncs.tenants_tenant_id = tenants_themes.tenant_id
            JOIN tenants ON tenants.id = migrator_syncs.tenant_id
            ON CONFLICT (id) DO NOTHING
          SQL
        end

        def data_attachments
          <<~SQL
            UPDATE active_storage_attachments
            SET
              record_type = 'Organizations::Theme'
            WHERE
              record_type = 'Tenants::Theme'
          SQL
        end
      end
    end
  end
end
