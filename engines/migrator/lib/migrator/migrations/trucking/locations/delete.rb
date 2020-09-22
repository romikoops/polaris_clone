# frozen_string_literal: true

module Migrator
  module Migrations
    module Trucking
      module Locations
        class Delete < Base
          depends_on "trucking/locations/update"

          def data
            <<~SQL
              UPDATE trucking_locations
              SET deleted_at = clock_timestamp()
              FROM migrator_unique_trucking_location_syncs
              WHERE trucking_locations.id = migrator_unique_trucking_location_syncs.duplicate_trucking_location_id
              AND trucking_locations.id != migrator_unique_trucking_location_syncs.unique_trucking_location_id
              AND deleted_at IS NULL;
            SQL
          end

          def count_required
            count("
              SELECT COUNT(*)
              FROM trucking_locations
              JOIN migrator_unique_trucking_location_syncs
              ON trucking_locations.id = migrator_unique_trucking_location_syncs.duplicate_trucking_location_id
              WHERE trucking_locations.id != migrator_unique_trucking_location_syncs.unique_trucking_location_id
              AND deleted_at IS NULL;
            ")
          end
        end
      end
    end
  end
end
