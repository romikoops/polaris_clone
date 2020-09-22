# frozen_string_literal: true

module Migrator
  module Migrations
    module Trucking
      module Locations
        class Backup < Base
          depends_on "trucking/locations/prepare"

          def data
            <<~SQL
              WITH sorted_trucking_locations AS (    
                SELECT trucking_locations.id AS duplicate_id, FIRST_VALUE(trucking_locations.id) OVER 
                (
                  PARTITION BY (data, query, country_id) 
                  ORDER BY location_id DESC NULLS LAST, data DESC, trucking_locations.created_at DESC
                ) unique_id
                FROM trucking_locations
                LEFT OUTER JOIN migrator_unique_trucking_location_syncs
                ON migrator_unique_trucking_location_syncs.duplicate_trucking_location_id = trucking_locations.id
                WHERE migrator_unique_trucking_location_syncs.duplicate_trucking_location_id IS NULL
                AND deleted_at IS NULL
              )
              INSERT INTO migrator_unique_trucking_location_syncs (
                duplicate_trucking_location_id, unique_trucking_location_id, created_at, updated_at
              )
              (SELECT duplicate_id, unique_id, now(), now()
                FROM sorted_trucking_locations
                WHERE unique_id != duplicate_id
              )
              ON CONFLICT DO NOTHING;
            SQL
          end

          def count_required
            count("
              WITH sorted_trucking_locations AS (
                SELECT trucking_locations.id AS duplicate_id, FIRST_VALUE(trucking_locations.id) OVER
                (
                  PARTITION BY (data, query, country_id)
                  ORDER BY location_id DESC NULLS LAST, data DESC, trucking_locations.created_at DESC
                ) unique_id
                FROM trucking_locations
                LEFT OUTER JOIN migrator_unique_trucking_location_syncs
                ON migrator_unique_trucking_location_syncs.duplicate_trucking_location_id = trucking_locations.id
                WHERE migrator_unique_trucking_location_syncs.duplicate_trucking_location_id IS NULL
                AND deleted_at IS NULL
              )
              SELECT COUNT(*)
              FROM sorted_trucking_locations
              WHERE unique_id != duplicate_id;
            ")
          end
        end
      end
    end
  end
end
