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
              FROM migrator_unique_tenant_vehicles_syncs
              WHERE migrator_unique_tenant_vehicles_syncs.duplicate_tenant_vehicle_id = tenant_vehicles.id
              AND deleted_at IS NULL
            SQL
          end

          def count_required
            count("
              SELECT COUNT(*)
               FROM tenant_vehicles
               JOIN migrator_unique_tenant_vehicles_syncs
               ON tenant_vehicles.id = migrator_unique_tenant_vehicles_syncs.duplicate_tenant_vehicle_id
               AND deleted_at IS NULL;
            ")
          end
        end
      end
    end
  end
end
