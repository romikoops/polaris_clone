# frozen_string_literal: true

module Migrator
  module Migrations
    module Legacy
      module Carriers
        class Backup < Base
          def data
            <<~SQL
              WITH partitions AS (
                SELECT carriers.id as dup_id, FIRST_VALUE(id) OVER
                  (PARTITION BY (carriers.code ) ORDER BY carriers.created_at DESC) unique_id
                FROM carriers
                WHERE code IS NOT NULL
                  AND deleted_at IS NULL)

              INSERT INTO migrator_unique_carrier_syncs (duplicate_carrier_id, unique_carrier_id, created_at, updated_at)
                (select dup_id, unique_id, now(), now() from partitions)
              ON CONFLICT(unique_carrier_id, duplicate_carrier_id) DO NOTHING;
            SQL
          end

          def count_required
            count("
              SELECT COUNT(*)
              FROM carriers
              WHERE code IS NOT NULL
              AND id NOT IN (select duplicate_carrier_id from migrator_unique_carrier_syncs);
            ")
          end
        end
      end
    end
  end
end
