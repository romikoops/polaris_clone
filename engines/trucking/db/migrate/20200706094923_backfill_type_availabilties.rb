# frozen_string_literal: true
class BackfillTypeAvailabilties < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      exec_delete(
        <<~SQL
          DELETE FROM
          trucking_type_availabilities
          WHERE
            country_id IS NULL
        SQL
      )
      exec_delete(
        <<~SQL
          DELETE FROM
          trucking_hub_availabilities
          WHERE
          type_availability_id IS NOT NULL
        SQL
      )
      exec_update(
        <<~SQL
          INSERT INTO trucking_type_availabilities (carriage, load_type, query_method, truck_type, country_id, created_at, updated_at)
          SELECT DISTINCT
            trucking_truckings.carriage,
            trucking_truckings.load_type,
            CASE
              WHEN trucking_locations.location_id IS NOT NULL  THEN 3
              WHEN trucking_locations.location_id IS NULL AND trucking_locations.zipcode IS NOT NULL THEN 2
              WHEN trucking_locations.location_id IS NULL AND trucking_locations.distance IS NOT NULL THEN 1
            END,
            trucking_truckings.truck_type,
            countries.id,
            current_timestamp,
            current_timestamp
          FROM trucking_truckings
          JOIN trucking_locations ON trucking_locations.id = trucking_truckings.location_id
          JOIN countries ON trucking_locations.country_code = countries.code
          ON CONFLICT (id) DO NOTHING;
        SQL
      )
      exec_update(
        <<~SQL
          INSERT INTO trucking_hub_availabilities (hub_id, type_availability_id, created_at, updated_at)
          SELECT DISTINCT
            hubs.id,
            trucking_type_availabilities.id,
            current_timestamp,
            current_timestamp
          FROM trucking_truckings
          JOIN hubs ON hubs.id = trucking_truckings.hub_id
          JOIN trucking_locations ON trucking_locations.id = trucking_truckings.location_id
          JOIN trucking_type_availabilities ON trucking_type_availabilities.carriage = trucking_truckings.carriage
            AND trucking_type_availabilities.load_type = trucking_truckings.load_type
            AND trucking_type_availabilities.truck_type = trucking_truckings.truck_type
          JOIN countries ON trucking_locations.country_code = countries.code
          WHERE countries.id = trucking_type_availabilities.country_id
          ON CONFLICT (id) DO NOTHING;
        SQL
      )
    end
  end

  def down
    exec_delete(
      <<~SQL
        DELETE FROM
        trucking_type_availabilities
        WHERE
          truck_type IS NOT NULL
      SQL
    )
    exec_delete(
      <<~SQL
        DELETE FROM
        trucking_hub_availabilities
        WHERE
        type_availability_id IS NOT NULL
      SQL
    )
  end
end
