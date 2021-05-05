# frozen_string_literal: true

class DedupeTruckingLocationsWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  BATCH_SIZE = 2000

  def perform
    total 8

    at 1, "Deleting Duplicates"

    ActiveRecord::Base.connection.execute(
      <<~SQL
        WITH sorted_trucking_locations AS (
        SELECT trucking_locations.id AS duplicate_id, FIRST_VALUE(trucking_locations.id) OVER (
            PARTITION BY (data, query, country_id)
            ORDER BY location_id DESC NULLS LAST, data DESC, trucking_locations.created_at DESC
        ) unique_id
            FROM trucking_locations
            WHERE deleted_at IS NULL
        )

        DELETE FROM trucking_locations
        USING sorted_trucking_locations
        WHERE trucking_locations.id = sorted_trucking_locations.duplicate_id
        AND trucking_locations.id != sorted_trucking_locations.unique_id
        AND deleted_at IS NULL;
      SQL
    )
    at 2, "Duplicates deleted"

    at 3, "Deleting Truckings"

    ActiveRecord::Base.connection.execute(
      <<~SQL
        UPDATE trucking_truckings
        SET deleted_at = clock_timestamp()
        FROM trucking_locations
        WHERE trucking_locations.id = trucking_truckings.location_id
        AND trucking_locations.deleted_at IS NOT NULL
        AND trucking_truckings.deleted_at IS NULL
      SQL
    )

    at 4, "Truckings deleted"

    at 5, "Deleting Soft Deleted Locations"

    ActiveRecord::Base.connection.execute(
      <<~SQL
        DELETE FROM trucking_locations
        WHERE deleted_at IS NOT NULL
      SQL
    )

    at 6, "Soft Deleted Locations deleted"

    at 7, "Setting Unique ID's"

    ActiveRecord::Base.connection.execute(
      <<~SQL
        UPDATE trucking_locations
        SET upsert_id = uuid_generate_v5('#{Trucking::Location::UUID_V5_NAMESPACE}', CONCAT(data::text, query::text, location_id::text, country_id::text)::text)
      SQL
    )

    at 8, "Unique ID set"
  end
end
