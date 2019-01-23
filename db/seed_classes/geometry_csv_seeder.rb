# frozen_string_literal: true

require 'csv'

class GeometryCsvSeeder
  TMP_PATH = 'tmp/tmp_csv.gz'
  def self.perform
    s3 = Aws::S3::Client.new
    bucket = 'assets.itsmycargo.com'
    puts 'Reading from csv...'

    # GeometryCsvSeeder.get_s3_file('data/germany.csv.gz')

    # Zlib::GzipReader.open(TMP_PATH) do |gz|
    #   csv = CSV.new(gz, headers: true)
    #   csv.each do |row|
    #     case row['place_type']
    #     when 'suburb'
    #       data = {
    #         suburb: row['name'],
    #         city: row['city'],
    #         bounds: RGeo::GeoJSON.decode(row['geojson']),
    #         country: 'Germany',
    #         postal_code: nil,
    #         province: nil
    #       }
    #     when 'neighbourhood'
    #       data = {
    #         neighbourhood: row['name'],
    #         city: row['city'],
    #         bounds: RGeo::GeoJSON.decode(row['geojson']),
    #         country: 'Germany',
    #         postal_code: nil,
    #         province: nil
    #       }
    #     end

    #     Location.import([data],
    #                     on_duplicate_key_update: {
    #                       conflict_target: %i(postal_code suburb neighbourhood city province country),
    #                       columns:         [:bounds]
    #                     })
    #   end
    # end
    # File.delete(TMP_PATH) if File.exist?(TMP_PATH)

    # puts 'Germany Geometries seeded...'

    GeometryCsvSeeder.get_s3_file('data/uk_areas.csv.gz')

    Zlib::GzipReader.open(TMP_PATH) do |gz|
      csv = CSV.new(gz, col_sep: "\t", quote_char: "'")

      csv.each do |row|
        Locations::Location.import([{
                          country: 'United Kingdom of Great Britain and Northern Ireland',
                          country_code: 'uk',
                          bounds: RGeo::GeoJSON.decode(row.second),
                          postal_code: row.first
                        }],
                        on_duplicate_key_update: {
                          conflict_target: %i(postal_code city province country),
                          columns:         %i(bounds)
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
        Locations::Location.import([{
                          country: 'United Kingdom of Great Britain and Northern Ireland',
                          country_code: 'uk',
                          bounds: RGeo::GeoJSON.decode(row.second),
                          postal_code: postal_code
                        }],
                        on_duplicate_key_update: {
                          conflict_target: %i(postal_code  city province country),
                          columns:         %i(bounds)
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
