# frozen_string_literal: true

module Migrator
  module Migrations
    module Legacy
      module TenantVehicles
        class Delete < Base
          depends_on "legacy/tenant_vehicles/update"

          def data
            <<~SQL
              UPDATE tenant_vehicles
              SET deleted_at = now()
              WHERE tenant_vehicles.id NOT IN
                (SELECT migrator_unique_tenant_vehicles_syncs.unique_tenant_vehicle_id
                 FROM migrator_unique_tenant_vehicles_syncs)
              AND tenant_vehicles.id IN
                (SELECT migrator_unique_tenant_vehicles_syncs.duplicate_tenant_vehicle_id
                 FROM migrator_unique_tenant_vehicles_syncs)
              AND deleted_at IS NULL
            SQL
          end

          def count_required
            count("
              SELECT COUNT(*)
              FROM tenant_vehicles
              WHERE tenant_vehicles.id NOT IN
                (SELECT migrator_unique_tenant_vehicles_syncs.unique_tenant_vehicle_id
                 FROM migrator_unique_tenant_vehicles_syncs)
              AND tenant_vehicles.id IN
                (SELECT migrator_unique_tenant_vehicles_syncs.duplicate_tenant_vehicle_id
                 FROM migrator_unique_tenant_vehicles_syncs)
              AND deleted_at IS NULL;
            ")
          end
        end
      end
    end
  end
end
