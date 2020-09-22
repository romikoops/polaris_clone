# frozen_string_literal: true

module Migrator
  module Migrations
    module Trucking
      module Truckings
        class Delete < Base
          depends_on "trucking/truckings/update"

          def data
            [remove_hub_less, remove_duplicates]
          end

          def remove_duplicates
            <<~SQL
              UPDATE trucking_truckings
              SET deleted_at = now()
              FROM migrator_unique_trucking_syncs
              WHERE trucking_truckings.id = migrator_unique_trucking_syncs.duplicate_trucking_id
              AND trucking_truckings.id != migrator_unique_trucking_syncs.unique_trucking_id
              AND unique_trucking_id IS NOT NULL
              AND hub_id IS NOT NULL
              AND deleted_at IS NULL
            SQL
          end

          def remove_hub_less
            <<~SQL
              UPDATE trucking_truckings
              SET deleted_at = now()
              WHERE hub_id IS NULL
              AND deleted_at IS NULL
            SQL
          end

          def count_required
            hub_less_count = count("
              SELECT COUNT(*)
              FROM trucking_truckings
              WHERE trucking_truckings.hub_id IS NULL
              AND deleted_at IS NULL
            ")

            duplicate_count = count("
              SELECT COUNT(*)
              FROM trucking_truckings
              JOIN migrator_unique_trucking_syncs
              ON trucking_truckings.id = migrator_unique_trucking_syncs.duplicate_trucking_id
              WHERE trucking_truckings.id != migrator_unique_trucking_syncs.unique_trucking_id
              AND unique_trucking_id IS NOT NULL
              AND deleted_at IS NULL
              AND hub_id IS NOT NULL
            ")

            [hub_less_count, duplicate_count]
          end
        end
      end
    end
  end
end
