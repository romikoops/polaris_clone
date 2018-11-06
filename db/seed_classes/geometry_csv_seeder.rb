# frozen_string_literal: true

require 'csv'

class GeometryCsvSeeder
  TMP_PATH = 'tmp/tmp_csv.gz'
  def self.perform
    s3 = Aws::S3::Client.new
    bucket = 'assets.itsmycargo.com'
    puts 'Reading from csv...'

    GeometryCsvSeeder.get_s3_file('data/germany.csv.gz')

    Zlib::GzipReader.open(TMP_PATH) do |gz|
      csv = CSV.new(gz, headers: true)
      csv.each do |row|
        Geometry.import([
                          {
                            name_1: row['name'],
                            name_2: row['name_1'],
                            name_3: row['name_2'],
                            name_4: row['name_3'],
                            data:   row['geojson']
                          }
                        ],
                        on_duplicate_key_update: {
                          conflict_target: %i(name_1 name_2 name_3 name_4),
                          columns:         %i(data)
                        })
      end
    end
    File.delete(TMP_PATH) if File.exist?(TMP_PATH)

    puts 'Germany Geometries seeded...'

    GeometryCsvSeeder.get_s3_file('data/uk_areas.csv.gz')

    Zlib::GzipReader.open(TMP_PATH) do |gz|
      csv = CSV.new(gz, col_sep: "\t", quote_char: "'")

      csv.each do |row|
        Geometry.import([{
                          name_1: 'United Kingdom of Great Britain and Northern Ireland',
                          name_2: row.first,
                          name_3: row.first,
                          name_4: row.first.capitalize,
                          data:   RGeo::GeoJSON.decode(row.second)
                        }],
                        on_duplicate_key_update: {
                          conflict_target: %i(name_1 name_2 name_3 name_4),
                          columns:         %i(data)
                        })
      end
    end
    File.delete(TMP_PATH) if File.exist?(TMP_PATH)

    puts 'UK Area Geometries seeded...'

    GeometryCsvSeeder.get_s3_file('data/uk_districts.csv.gz')

    Zlib::GzipReader.open(TMP_PATH) do |gz|
      csv = CSV.new(gz, col_sep: "\t", quote_char: "'")

      csv.each do |row|
        postal_code = row.first
        area_code, = postal_code.match(/([A-Z]+)(\d+)/).captures
        Geometry.import([{
                          name_1: 'United Kingdom of Great Britain and Northern Ireland',
                          name_2: area_code,
                          name_3: area_code.capitalize,
                          name_4: postal_code,
                          data:   RGeo::GeoJSON.decode(row.second)
                        }],
                        on_duplicate_key_update: {
                          conflict_target: %i(name_1 name_2 name_3 name_4),
                          columns:         %i(data)
                        })
      end
    end
    File.delete(TMP_PATH) if File.exist?(TMP_PATH)

    puts 'UK Districts Geometries seeded...'
  end

  def self.get_s3_file(key)
    s3 = Aws::S3::Client.new

    file = s3.get_object(
      bucket: 'assets.itsmycargo.com',
      key: key,
      response_content_disposition: 'application/x-gzip'
    ).body.read

    File.open(TMP_PATH, 'wb') { |f| f.write(file) }
  end
end
