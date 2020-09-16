# frozen_string_literal: true

module Migrator
  module Migrations
    module Legacy
      module Carriers
        class Update < Base
          depends_on "legacy/carriers/backup"

          REFERENCING_TABLES = {
            "max_dimensions_bundles" => ["carrier_id"],
            "tenant_vehicles" => ["carrier_id"]
          }

          def data
            @statements ||= begin
              statements = []

              REFERENCING_TABLES.each do |table, columns|
                columns.each do |column|
                  statements << <<~SQL
                    UPDATE #{table}
                      SET #{column} = migrator_unique_carrier_syncs.unique_carrier_id
                    FROM migrator_unique_carrier_syncs
                    WHERE #{table}.#{column} = migrator_unique_carrier_syncs.duplicate_carrier_id
                    AND #{table}.#{column} != migrator_unique_carrier_syncs.unique_carrier_id
                  SQL
                end
              end

              statements
            end
          end

          def count_required
            @counts ||= begin
              counts = []

              REFERENCING_TABLES.each do |table, columns|
                columns.each do |column|
                  counts << count("
                    SELECT COUNT(*)
                    FROM #{table}
                    JOIN migrator_unique_carrier_syncs
                    ON #{table}.#{column} = migrator_unique_carrier_syncs.duplicate_carrier_id
                    WHERE #{table}.#{column} != migrator_unique_carrier_syncs.unique_carrier_id;
                  ")
                end
              end

              counts
            end
          end
        end
      end
    end
  end
end
