# frozen_string_literal: true

module Migrator
  module Migrations
    module Legacy
      module TenantVehicles
        class Backup < Base
          depends_on "legacy/carriers/update"

          def data
            <<~SQL
              WITH partitions AS (
                SELECT tenant_vehicles.id as dup_id, FIRST_VALUE(id) OVER
                  (PARTITION BY (tenant_vehicles.organization_id, tenant_vehicles.name, tenant_vehicles.mode_of_transport, tenant_vehicles.carrier_id )
                ORDER BY tenant_vehicles.created_at DESC) unique_id
                FROM tenant_vehicles
                WHERE deleted_at IS NULL)

              INSERT INTO migrator_unique_tenant_vehicles_syncs (duplicate_tenant_vehicle_id, unique_tenant_vehicle_id, created_at, updated_at)
                (select dup_id, unique_id, now(), now() from partitions)
                ON CONFLICT(unique_tenant_vehicle_id, duplicate_tenant_vehicle_id) DO NOTHING;
            SQL
          end

          def count_required
            count("
              SELECT COUNT(*)
              FROM tenant_vehicles
              WHERE id NOT IN (select duplicate_tenant_vehicle_id from migrator_unique_tenant_vehicles_syncs);
            ")
          end
        end
      end
    end
  end
end
