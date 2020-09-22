# frozen_string_literal: true

module Migrator
  module Migrations
    module Trucking
      module Locations
        class Prepare < Base
          def data
            [update_hidden_postal_codes, update_hidden_distances, set_new_attributes]
          end

          def update_hidden_postal_codes
            <<~SQL
              UPDATE trucking_locations
              SET zipcode = hidden_postal_code_location.zipcode
              FROM trucking_locations hidden_postal_code_location
              WHERE trucking_locations.zipcode = hidden_postal_code_location.city_name
              AND hidden_postal_code_location.country_code = trucking_locations.country_code
              AND trucking_locations.zipcode IS NULL
              AND hidden_postal_code_location.zipcode IS NOT NULL;
            SQL
          end

          def update_hidden_distances
            <<~SQL
              UPDATE trucking_locations
              SET city_name = distance::text
              WHERE city_name IS NULL
              AND distance IS NOT NULL
              AND deleted_at is NULL;
            SQL
          end

          def set_new_attributes
            <<~SQL
              UPDATE trucking_locations
              SET data = trucking_locations.city_name, country_id = countries.id, query = CASE
                WHEN trucking_locations.zipcode IS NOT NULL AND trucking_locations.distance IS NULL THEN 1
                WHEN trucking_locations.zipcode IS NULL AND trucking_locations.distance IS NULL THEN 2
                WHEN trucking_locations.zipcode IS NULL AND trucking_locations.distance IS NOT NULL THEN 3
                WHEN trucking_locations.city_name IS NULL THEN 0
                ELSE 0
              END
              FROM countries
              WHERE countries.code = trucking_locations.country_code
              AND trucking_locations.data IS NULL
              AND trucking_locations.query IS NULL
              AND trucking_locations.country_id IS NULL
              AND trucking_locations.deleted_at is NULL
            SQL
          end

          def count_required
            [
              update_hidden_postal_codes_count,
              update_hidden_distances_count,
              updated_attributes_count
            ]
          end

          def update_hidden_postal_codes_count
            count("
              SELECT COUNT(*)
              FROM trucking_locations
              JOIN trucking_locations hidden_postal_code_location
              ON trucking_locations.zipcode = hidden_postal_code_location.city_name
              AND hidden_postal_code_location.country_code = trucking_locations.country_code
              WHERE trucking_locations.zipcode IS NULL
              AND hidden_postal_code_location.zipcode IS NOT NULL
              AND trucking_locations.deleted_at is NULL;
            ")
          end

          def update_hidden_distances_count
            count("
              SELECT COUNT(*)
              FROM trucking_locations
              WHERE distance IS NOT NULL
              AND city_name IS NULL
              AND deleted_at is NULL
            ")
          end

          def updated_attributes_count
            count("
              SELECT COUNT(*)
              FROM trucking_locations
              JOIN countries
              ON countries.code = trucking_locations.country_code
              AND trucking_locations.data IS NULL
              AND trucking_locations.query IS NULL
              AND trucking_locations.country_id IS NULL
              AND trucking_locations.deleted_at is NULL
            ")
          end
        end
      end
    end
  end
end
