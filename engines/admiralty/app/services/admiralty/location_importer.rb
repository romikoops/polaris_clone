# frozen_string_literal: true

module Admiralty
  # The location importer will either take a csv file or a pull the data from the datahub bucket to create Locations::Location and Trucking Location models for use in trucking uploads
  class LocationImporter
    attr_reader :country, :file

    delegate :code, :csv_path, to: :country

    def initialize(country:, file: nil)
      @country = country
      @file = file
    end

    def perform
      ActiveRecord::Base.transaction do
        create_temp_table
        import_data_into_temp_table
        connection.execute(insert_locations_locations)
        connection.execute(insert_trucking_locations)
      end
    ensure
      drop_temp_table
    end

    def connection
      @connection ||= ActiveRecord::Base.connection
    end

    delegate :raw_connection, to: :connection

    def import_s3_data_into_temp_table
      client.get_object(bucket: "itsmycargo-datahub", key: csv_path, response_content_type: "text/csv") do |chunk, _headers|
        raw_connection.put_copy_data(chunk)
      end
    end

    def import_file_data_into_temp_table
      File.open(file.path, "r") do |chunk|
        while (line = chunk.gets)
          raw_connection.put_copy_data(line)
        end
      end
    end

    def import_data_into_temp_table
      raw_connection.copy_data %(copy locations_tmp_import from stdin with csv header delimiter ',' quote '"') do
        file.present? ? import_file_data_into_temp_table : import_s3_data_into_temp_table
      end
    end

    def create_temp_table
      drop_temp_table
      connection.execute <<-SQL
        CREATE TEMP TABLE locations_tmp_import
        (
          name character varying,
          id character varying,
          country character varying,
          point geometry,
          polygon geometry
        )
      SQL
    end

    def drop_temp_table
      connection.execute <<-SQL
        DROP TABLE IF EXISTS locations_tmp_import;
      SQL
    end

    def client
      @client ||= Aws::S3::Client.new
    end

    def insert_locations_locations
      "INSERT INTO locations_locations (
        bounds,
        name,
        country_code,
        created_at,
        updated_at
      )
      SELECT
        ST_SetSRID(li.polygon, 4326) as bounds,
        li.name as name,
        LOWER(li.country) as country_code,
        current_timestamp,
        current_timestamp
      FROM locations_tmp_import li
      ON CONFLICT (name, country_code)
      DO UPDATE
      SET bounds = EXCLUDED.bounds, updated_at = now()"
    end

    def insert_trucking_locations
      "insert into trucking_locations (
        query,
        data,
        country_id,
        location_id,
        upsert_id,
        created_at,
        updated_at
      )
      select
        1 as query,
        li.name,
        countries.id,
        locations_locations.id,
        uuid_generate_v5('#{Trucking::Location::UUID_V5_NAMESPACE}', CONCAT(li.name::text, '1'::text, locations_locations.id::text, countries.id::text)::text),
        current_timestamp,
        current_timestamp
      from locations_tmp_import li
      JOIN countries on countries.code = li.country
      JOIN locations_locations on LOWER(locations_locations.country_code) = LOWER(li.country)
        AND locations_locations.name = li.name
      ON CONFLICT DO NOTHING"
    end
  end
end
