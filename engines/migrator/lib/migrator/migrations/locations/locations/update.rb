# frozen_string_literal: true

module Migrator
  module Migrations
    module Locations
      module Locations
        class Update < Base
          depends_on "locations/locations/backup"

          def data
            @data ||= countries.map { |country_code|
              <<~SQL
                #{common_table_expressions(country_code: country_code)}
                UPDATE locations_locations
                SET bounds = collected_locations.bounds
                FROM migrator_unique_locations_locations_syncs
                JOIN locations_locations unique_locations
                  ON migrator_unique_locations_locations_syncs.unique_location_location_id = unique_locations.id
                JOIN collected_locations
                  ON unique_locations.name = collected_locations.name
                WHERE unique_locations.id = locations_locations.id
                AND unique_locations.country_code = '#{country_code}'
              SQL
            }
          end

          def count_required
            countries.map { |country_code|
              count("
                #{common_table_expressions(country_code: country_code)}
                SELECT COUNT(*) FROM collected_locations
              ")
            }
          end

          def common_table_expressions(country_code:)
            <<~SQL
              WITH valid_locations AS (
                SELECT * FROM locations_locations
                  WHERE country_code = '#{country_code}'
                  AND deleted_at IS NULL
              ), duplicated_locations AS (
                SELECT * FROM valid_locations
                WHERE id IN (
                  (SELECT duplicate_location_location_id FROM migrator_unique_locations_locations_syncs)
                  UNION
                  (SELECT unique_location_location_id FROM migrator_unique_locations_locations_syncs)
                )
              ), collected_locations AS (
                SELECT name, ST_Collect(bounds) bounds
                  FROM duplicated_locations
                  GROUP BY name
              )
            SQL
          end

          def countries
            @countries ||= ::Locations::Location.where.not(country_code: ["", nil])
              .select(:country_code)
              .distinct
              .pluck(:country_code)
          end
        end
      end
    end
  end
end
