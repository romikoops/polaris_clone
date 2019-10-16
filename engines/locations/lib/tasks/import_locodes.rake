# frozen_string_literal: true

namespace :locations do
  task import_locodes: :environment do
    url_data = Aws::S3::Client.new.get_object(
      bucket: 'assets.itsmycargo.com',
      key: 'data/location_data/polygon_locode.csv'
    ).body.read
    temp_file = Tempfile.new
    temp_file.write(url_data)
    temp_file.rewind
    Locations::Location.connection.execute <<-SQL
          DROP TABLE IF EXISTS locations_locode_import;
          CREATE TEMP TABLE locations_locode_import
          (
            polygon geometry,
            locode_country character varying,
            locode_location character varying
          )
    SQL

    File.open(temp_file.path, 'r') do |file|
      Locations::Location.connection.raw_connection.copy_data %(copy locations_locode_import from stdin with csv delimiter ',' quote '"' ) do
        while line = file.gets
          Locations::Location.connection.raw_connection.put_copy_data(line)
        end
      end
    end
    insert = "insert into locations_locations (
      bounds,
      name,
      country_code,
      created_at,
      updated_at
    )
    select
      li.polygon,
      CONCAT(li.locode_country, li.locode_location),
      LOWER(li.locode_country),
      current_timestamp,
      current_timestamp
    from locations_locode_import li
    on conflict do nothing"
      
    Locations::Location.connection.execute(insert)
    temp_file.unlink
  end
end
