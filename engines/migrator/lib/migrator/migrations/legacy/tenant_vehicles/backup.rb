module Migrator
  module Migrations
    module Legacy
      module TenantVehicles
        class Backup < Base
          def data
            <<~SQL
              WITH partitions AS (
                SELECT tenant_vehicles.id as duplicate_id, FIRST_VALUE(tenant_vehicles.id) OVER
                (
                  PARTITION BY (
                    tenant_vehicles.organization_id,
                    tenant_vehicles.name,
                    tenant_vehicles.mode_of_transport,
                    tenant_vehicles.carrier_id
                  )
                  ORDER BY tenant_vehicles.id DESC
                ) unique_id
                FROM tenant_vehicles

                LEFT OUTER JOIN migrator_unique_tenant_vehicles_syncs
                ON migrator_unique_tenant_vehicles_syncs.duplicate_tenant_vehicle_id = tenant_vehicles.id
                WHERE migrator_unique_tenant_vehicles_syncs.duplicate_tenant_vehicle_id IS NULL
                AND deleted_at IS NULL
              )
              INSERT INTO migrator_unique_tenant_vehicles_syncs (
                duplicate_tenant_vehicle_id, unique_tenant_vehicle_id, created_at, updated_at
              )
              (SELECT duplicate_id, unique_id, now(), now()
               FROM partitions
               WHERE unique_id != duplicate_id)
              ON CONFLICT DO NOTHING;
            SQL
          end

          def count_required
            count("
              WITH partitions AS (
                SELECT tenant_vehicles.id as duplicate_id, FIRST_VALUE(tenant_vehicles.id) OVER
                (
                  PARTITION BY (
                    tenant_vehicles.organization_id,
                    tenant_vehicles.name,
                    tenant_vehicles.mode_of_transport,
                    tenant_vehicles.carrier_id
                  )
                  ORDER BY tenant_vehicles.id DESC
                ) unique_id
                FROM tenant_vehicles
                LEFT OUTER JOIN migrator_unique_tenant_vehicles_syncs
                ON migrator_unique_tenant_vehicles_syncs.duplicate_tenant_vehicle_id = tenant_vehicles.id
                WHERE migrator_unique_tenant_vehicles_syncs.duplicate_tenant_vehicle_id IS NULL
                AND deleted_at IS NULL
              )
              SELECT COUNT(*)
                FROM partitions
                WHERE unique_id != duplicate_id;
            ")
          end
        end
      end
    end
  end
end
