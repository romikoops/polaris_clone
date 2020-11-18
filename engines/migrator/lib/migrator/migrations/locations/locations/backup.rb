# frozen_string_literal: true

module Migrator
  module Migrations
    module Locations
      module Locations
        class Backup < Base
          def data
            <<~SQL
              WITH sorted_locations_locations AS (
                SELECT locations_locations.id duplicate_id, FIRST_VALUE(locations_locations.id) OVER 
                (PARTITION BY (name, country_code) ORDER BY locations_locations.created_at DESC) unique_id
                FROM locations_locations
                LEFT OUTER JOIN migrator_unique_locations_locations_syncs
                  ON migrator_unique_locations_locations_syncs.duplicate_location_location_id = locations_locations.id
                WHERE migrator_unique_locations_locations_syncs.duplicate_location_location_id IS NULL
                AND deleted_at IS NULL
                AND name IS NOT NULL
                AND country_code IS NOT NULL
                )
                INSERT INTO migrator_unique_locations_locations_syncs (unique_location_location_id, duplicate_location_location_id, created_at, updated_at)
                (SELECT unique_id, duplicate_id, now(), now()
                  FROM sorted_locations_locations
                  WHERE unique_id != duplicate_id
                )
                ON CONFLICT DO NOTHING;
            SQL
          end

          def count_required
            count("
              WITH sorted_locations_locations AS (
                SELECT locations_locations.id duplicate_id, FIRST_VALUE(locations_locations.id) OVER
                (PARTITION BY (name, country_code) ORDER BY locations_locations.created_at DESC) unique_id
                FROM locations_locations
                LEFT OUTER JOIN migrator_unique_locations_locations_syncs
                  ON migrator_unique_locations_locations_syncs.duplicate_location_location_id = locations_locations.id
                WHERE migrator_unique_locations_locations_syncs.duplicate_location_location_id IS NULL
                AND deleted_at IS NULL
                AND name IS NOT NULL
                AND country_code IS NOT NULL
                )
              SELECT COUNT(*)
              FROM sorted_locations_locations
              WHERE unique_id != duplicate_id;
            ")
          end
        end
      end
    end
  end
end
