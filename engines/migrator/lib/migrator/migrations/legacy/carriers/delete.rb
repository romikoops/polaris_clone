module Migrator
  module Migrations
    module Legacy
      module Carriers
        class Delete < Base
          depends_on "legacy/carriers/update"

          def data
            [delete_duplicates, delete_no_codes]
          end

          def delete_duplicates
            <<~SQL
              UPDATE carriers
              SET deleted_at = now()
              WHERE carriers.id NOT IN
                (SELECT migrator_unique_carrier_syncs.unique_carrier_id
                 FROM migrator_unique_carrier_syncs)
              AND carriers.id IN
                (SELECT migrator_unique_carrier_syncs.duplicate_carrier_id
                FROM migrator_unique_carrier_syncs)
              AND deleted_at IS NULL
            SQL
          end

          def delete_no_codes
            <<~SQL
              UPDATE carriers
              SET deleted_at = now()
              WHERE carriers.code IS NULL
              AND deleted_at IS NULL
            SQL
          end

          def count_required
            [
              count("
                SELECT COUNT(*)
                FROM carriers
                WHERE carriers.id NOT IN
                  (SELECT migrator_unique_carrier_syncs.unique_carrier_id
                  FROM migrator_unique_carrier_syncs)
                AND carriers.id IN
                  (SELECT migrator_unique_carrier_syncs.duplicate_carrier_id
                  FROM migrator_unique_carrier_syncs)
                AND deleted_at IS NULL;
              "),
              count("
                SELECT COUNT(*)
                FROM carriers
                WHERE carriers.code IS NULL
                AND deleted_at IS NULL;
              ")
            ]
          end
        end
      end
    end
  end
end
