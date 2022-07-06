# frozen_string_literal: true

class DeduplicateTruckingLocationAgainWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  BATCH_SIZE = 2000

  def perform
    ActiveRecord::Base.transaction do
      create_temp_table
      delete_invalid_locations
      delete_truckings_attached_to_invalid_locations
      destroy_duplicate_locations
      reassign_upsert_ids
    end
  ensure
    connection.drop_table(:duplicate_trucking_locations, if_exists: true)
  end

  def connection
    @connection ||= ActiveRecord::Base.connection
  end

  def create_temp_table
    connection.drop_table(:duplicate_trucking_locations, if_exists: true)
    connection.create_table(
      :duplicate_trucking_locations,
      temporary: true,
      as: "SELECT trucking_locations.id AS duplicate_id, FIRST_VALUE(trucking_locations.id) OVER (
        PARTITION BY (data, query, country_id)
        ORDER BY trucking_locations.created_at DESC
    ) unique_id
        FROM trucking_locations
        WHERE deleted_at IS NULL"
    )
  end

  def delete_invalid_locations
    connection.execute(
      <<~SQL.squish
        DELETE FROM trucking_locations
        WHERE trucking_locations.query = 1
        AND trucking_locations.location_id IS NULL
        AND deleted_at IS NULL;
      SQL
    )

    connection.execute(
      <<~SQL.squish
        DELETE FROM trucking_locations
        USING locations_locations
        WHERE trucking_locations.query = 1
        AND trucking_locations.location_id = locations_locations.id
        AND locations_locations.admin_level < 4
        AND locations_locations.admin_level IS NOT NULL
        AND trucking_locations.deleted_at IS NULL;
      SQL
    )
  end

  def delete_truckings_attached_to_invalid_locations
    connection.execute(
      <<~SQL.squish
        UPDATE trucking_truckings
        SET deleted_at = clock_timestamp()
        FROM trucking_locations
        WHERE trucking_locations.id = trucking_truckings.location_id
        AND trucking_locations.deleted_at IS NOT NULL
        AND trucking_truckings.deleted_at IS NULL
      SQL
    )
    connection.execute(
      <<~SQL.squish
        UPDATE trucking_truckings
        SET deleted_at = clock_timestamp()
        FROM duplicate_trucking_locations
        WHERE duplicate_trucking_locations.duplicate_id = trucking_truckings.location_id
        AND trucking_truckings.deleted_at IS NULL
      SQL
    )
  end

  def destroy_duplicate_locations
    connection.execute(
      <<~SQL.squish
        DELETE FROM trucking_locations
        USING duplicate_trucking_locations
        WHERE trucking_locations.id = duplicate_trucking_locations.duplicate_id
        AND trucking_locations.id != duplicate_trucking_locations.unique_id
        AND deleted_at IS NULL;
      SQL
    )

    connection.execute(
      <<~SQL.squish
        UPDATE trucking_truckings
        SET deleted_at = clock_timestamp()
        FROM trucking_locations
        WHERE trucking_locations.id = trucking_truckings.location_id
        AND trucking_locations.deleted_at IS NOT NULL
        AND trucking_truckings.deleted_at IS NULL
      SQL
    )
  end

  def reassign_upsert_ids
    Trucking::Location.queries.each do |string, int|
      connection.execute(
        <<~SQL.squish
          UPDATE trucking_locations
          SET upsert_id = uuid_generate_v5('#{Trucking::Location::UUID_V5_NAMESPACE}', CONCAT(data::text, '#{string}', country_id::text)::text)
          where query = #{int}
        SQL
      )
    end
  end
end
