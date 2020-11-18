# frozen_string_literal: true

module Migrator
  module Migrations
    module Locations
      module Locations
        class Delete < Base
          depends_on "locations/locations/replace"

          def data
            <<~SQL
              UPDATE locations_locations
              SET deleted_at = clock_timestamp()
              FROM migrator_unique_locations_locations_syncs
              WHERE migrator_unique_locations_locations_syncs.duplicate_location_location_id = locations_locations.id
              AND deleted_at IS NULL
            SQL
          end

          def count_required
            count("
              SELECT COUNT(*)
              FROM locations_locations
              JOIN migrator_unique_locations_locations_syncs
                ON migrator_unique_locations_locations_syncs.duplicate_location_location_id = locations_locations.id
              WHERE deleted_at IS NULL
            ")
          end
        end
      end
    end
  end
end
