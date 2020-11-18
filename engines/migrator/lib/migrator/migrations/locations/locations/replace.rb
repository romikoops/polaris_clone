# frozen_string_literal: true

module Migrator
  module Migrations
    module Locations
      module Locations
        class Replace < Base
          depends_on "locations/locations/update"

          def data
            [trucking_locations, locations_names]
          end

          def trucking_locations
            <<~SQL
              UPDATE trucking_locations
              SET location_id = migrator_unique_locations_locations_syncs.unique_location_location_id
              FROM migrator_unique_locations_locations_syncs
              WHERE location_id = migrator_unique_locations_locations_syncs.duplicate_location_location_id
              AND trucking_locations.deleted_at IS NULL
            SQL
          end

          def locations_names
            <<~SQL
              UPDATE locations_names
              SET location_id = migrator_unique_locations_locations_syncs.unique_location_location_id
              FROM migrator_unique_locations_locations_syncs
              WHERE location_id = migrator_unique_locations_locations_syncs.duplicate_location_location_id;
            SQL
          end

          def count_required
            [trucking_location_count, location_name_count]
          end

          def trucking_location_count
            count("
              SELECT COUNT(*)
              FROM trucking_locations
              JOIN migrator_unique_locations_locations_syncs
                ON migrator_unique_locations_locations_syncs.duplicate_location_location_id =
                 trucking_locations.location_id
              WHERE trucking_locations.deleted_at IS NULL;
            ")
          end

          def location_name_count
            count("
              SELECT COUNT(*)
              FROM locations_names
              JOIN migrator_unique_locations_locations_syncs
                ON migrator_unique_locations_locations_syncs.duplicate_location_location_id =
                 locations_names.location_id;
            ")
          end
        end
      end
    end
  end
end
