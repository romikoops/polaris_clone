module Migrator
  module Migrations
    module Legacy
      module TenantVehicles
        class Update < Base
          depends_on "legacy/tenant_vehicles/backup"

          REFERENCING_TABLES = {
            "local_charges" => ["tenant_vehicle_id"],
            "trips" => ["tenant_vehicle_id"],
            "max_dimensions_bundles" => ["tenant_vehicle_id"],
            "addons" => ["tenant_vehicle_id"],
            "customs_fees" => ["tenant_vehicle_id"],
            "pricings_pricings" => ["tenant_vehicle_id"],
            "pricings_margins" => ["tenant_vehicle_id"],
            "quotations_tenders" => ["tenant_vehicle_id", "pickup_tenant_vehicle_id", "delivery_tenant_vehicle_id"],
            "charge_breakdowns" => ["freight_tenant_vehicle_id",
              "pickup_tenant_vehicle_id",
              "delivery_tenant_vehicle_id"]
          }

          def data
            [*other_tables, *trucking]
          end

          def other_tables
            @statements ||= begin
              statements = []

              REFERENCING_TABLES.each do |table, columns|
                columns.each do |column|
                  statements << <<~SQL
                    UPDATE #{table}
                      SET #{column} = migrator_unique_tenant_vehicles_syncs.unique_tenant_vehicle_id
                    FROM migrator_unique_tenant_vehicles_syncs
                    WHERE #{table}.#{column} = migrator_unique_tenant_vehicles_syncs.duplicate_tenant_vehicle_id
                  SQL
                end
              end

              statements
            end
          end

          def trucking
            org_ids.map do |org_id|
              <<~SQL
                UPDATE trucking_truckings
                  SET tenant_vehicle_id = migrator_unique_tenant_vehicles_syncs.unique_tenant_vehicle_id
                FROM migrator_unique_tenant_vehicles_syncs
                WHERE trucking_truckings.tenant_vehicle_id = migrator_unique_tenant_vehicles_syncs.duplicate_tenant_vehicle_id
                AND trucking_truckings.organization_id = '#{org_id}'
              SQL
            end
          end

          def count_required
            [*other_tables_counts, *trucking_counts]
          end

          def other_tables_counts
            @counts ||= begin
              counts = []

              REFERENCING_TABLES.each do |table, columns|
                columns.each do |column|
                  counts << count("
                    SELECT COUNT(*)
                    FROM #{table}
                    JOIN migrator_unique_tenant_vehicles_syncs
                    ON #{table}.#{column} = migrator_unique_tenant_vehicles_syncs.duplicate_tenant_vehicle_id
                    WHERE #{table}.#{column} != migrator_unique_tenant_vehicles_syncs.unique_tenant_vehicle_id;
                  ")
                end
              end

              counts
            end
          end

          def trucking_counts
            org_ids.map do |org_id|
              count("
                SELECT COUNT(*)
                FROM trucking_truckings
                JOIN migrator_unique_tenant_vehicles_syncs
                ON
                trucking_truckings.tenant_vehicle_id = migrator_unique_tenant_vehicles_syncs.duplicate_tenant_vehicle_id
                WHERE
                 trucking_truckings.tenant_vehicle_id != migrator_unique_tenant_vehicles_syncs.unique_tenant_vehicle_id
                AND trucking_truckings.organization_id = '#{org_id}';
              ")
            end
          end

          def org_ids
            Organizations::Organization.order(:id).ids
          end
        end
      end
    end
  end
end
