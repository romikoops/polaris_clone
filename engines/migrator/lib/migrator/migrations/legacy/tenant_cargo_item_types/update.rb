# frozen_string_literal: true

module Migrator
  module Migrations
    module Legacy
      module TenantCargoItemTypes
        class Update < Base
          def data
            <<~SQL
              INSERT INTO tenant_cargo_item_types (organization_id, cargo_item_type_id, created_at, updated_at)		
                  (SELECT organizations_organizations.id, cargo_item_types.id, now(), now()
                  FROM organizations_organizations
                  JOIN cargo_item_types
                    ON cargo_item_types.description = 'Pallet'
                  LEFT OUTER JOIN  tenant_cargo_item_types missing_types
                  ON missing_types.organization_id = organizations_organizations.id
                  WHERE missing_types.organization_id IS NULL
                )
                ON CONFLICT DO NOTHING;
            SQL
          end

          def count_required
            count("
                SELECT COUNT(*)
                FROM organizations_organizations
                JOIN cargo_item_types
                  ON cargo_item_types.description = 'Pallet'
                LEFT OUTER JOIN  tenant_cargo_item_types missing_types
                ON missing_types.organization_id = organizations_organizations.id
                WHERE missing_types.organization_id IS NULL
            ")
          end
        end
      end
    end
  end
end
