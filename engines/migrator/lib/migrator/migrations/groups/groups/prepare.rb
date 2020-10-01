module Migrator
  module Migrations
    module Groups
      module Groups
        class Prepare < Base
          def data
            <<~SQL
              INSERT INTO groups_groups (
                name,
                organization_id,
                created_at,
                updated_at
              )
              SELECT 'default', organizations_organizations.id, now(), now()
                FROM organizations_organizations
                LEFT OUTER JOIN groups_groups
                  ON groups_groups.organization_id = organizations_organizations.id
                WHERE groups_groups.organization_id IS NULL
                AND groups_groups.name = 'default'
              ON CONFLICT DO NOTHING
            SQL
          end

          def count_required
            count("
              SELECT COUNT(*)
              FROM organizations_organizations
              LEFT OUTER JOIN groups_groups
                ON groups_groups.organization_id = organizations_organizations.id
              WHERE groups_groups.organization_id IS NULL
              AND groups_groups.name = 'default'
            ")
          end
        end
      end
    end
  end
end
