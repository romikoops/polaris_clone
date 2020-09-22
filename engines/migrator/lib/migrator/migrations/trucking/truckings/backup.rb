# frozen_string_literal: true

module Migrator
  module Migrations
    module Trucking
      module Truckings
        class Backup < Base
          def data
            @statements ||= organization_ids.map { |organization_id|
              <<~SQL
                WITH sorted_truckings AS (
                  SELECT trucking_truckings.id duplicate_id, FIRST_VALUE(trucking_truckings.id) OVER 
                  (PARTITION BY (
                    hub_id, carriage, load_type, cargo_class, location_id, organization_id,
                    truck_type,group_id,tenant_vehicle_id
                  ) ORDER BY trucking_truckings.created_at DESC) unique_id
                  FROM trucking_truckings
                  LEFT OUTER JOIN migrator_unique_trucking_syncs
                    ON migrator_unique_trucking_syncs.duplicate_trucking_id = trucking_truckings.id
                  WHERE migrator_unique_trucking_syncs.duplicate_trucking_id IS NULL
                  AND deleted_at IS NULL
                  AND organization_id = '#{organization_id}'
                  )
                  INSERT INTO migrator_unique_trucking_syncs (unique_trucking_id, duplicate_trucking_id, created_at, updated_at)
                  (SELECT unique_id, duplicate_id, now(), now()
                    FROM sorted_truckings
                    WHERE unique_id != duplicate_id
                  )
                  ON CONFLICT DO NOTHING;
              SQL
            }
          end

          def count_required
            @counts ||= organization_ids.map { |organization_id|
              count("
                WITH sorted_truckings AS (
                  SELECT trucking_truckings.id duplicate_id, FIRST_VALUE(trucking_truckings.id) OVER
                  (PARTITION BY (
                    hub_id, carriage, load_type, cargo_class, location_id, organization_id,
                    truck_type,group_id,tenant_vehicle_id
                  ) ORDER BY trucking_truckings.created_at DESC) unique_id
                  FROM trucking_truckings
                  LEFT OUTER JOIN migrator_unique_trucking_syncs
                    ON migrator_unique_trucking_syncs.duplicate_trucking_id = trucking_truckings.id
                  WHERE migrator_unique_trucking_syncs.duplicate_trucking_id IS NULL
                  AND deleted_at IS NULL
                  AND organization_id = '#{organization_id}'
                  )
                SELECT COUNT(*)
                FROM sorted_truckings
                WHERE unique_id != duplicate_id;
              ")
            }
          end

          def organization_ids
            Organizations::Organization.ids
          end
        end
      end
    end
  end
end
