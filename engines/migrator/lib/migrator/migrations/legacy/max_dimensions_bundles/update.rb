# frozen_string_literal: true

module Migrator
  module Migrations
    module Legacy
      module MaxDimensionsBundles
        class Update < Base
          def data
            <<~SQL
              INSERT INTO max_dimensions_bundles (
                organization_id,
                mode_of_transport,
                cargo_class,
                width,
                height,
                length,
                payload_in_kg,
                volume,
                chargeable_weight,
                created_at,
                updated_at
              )		
              (SELECT 
                organizations_organizations.id,
                'general',
                'lcl',
                1000,
                1000,
                1000,
                21700,
                1000,
                21700,
                now(),
                now()
                  FROM organizations_organizations
                  LEFT OUTER JOIN max_dimensions_bundles missing_types
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
                LEFT OUTER JOIN max_dimensions_bundles missing_types
                ON missing_types.organization_id = organizations_organizations.id
                WHERE missing_types.organization_id IS NULL
            ")
          end
        end
      end
    end
  end
end
