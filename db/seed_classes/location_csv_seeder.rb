# frozen_string_literal: true

require 'csv'

class LocationCsvSeeder # rubocop:disable Metrics/ClassLength
  TMP_PATH = 'tmp/tmp_csv.gz'
  def self.perform
    load_names_from_csv
  end

  def self.load_names_from_csv
    s3_url = 'data/location_data/locations_names_dump.csv.gz'
    LocationCsvSeeder.get_s3_file(s3_url)
    Zlib::GzipReader.open(TMP_PATH) do |gz|
      csv = CSV.new(gz, headers: true)
      names = []
      csv.each do |row|
        names << row.to_hash
        next unless names.length > 100

        begin
          Locations::Name.import(names)
          names = []
        rescue StandardError => e
          Rails.logger e
        end
      end

      Locations::Name.import(names)
    end
  end

  def self.load_map_data(url)
    LocationCsvSeeder.get_s3_file(url)

    Zlib::GzipReader.open(TMP_PATH) do |gz|
      csv = CSV.new(gz, headers: true)
      puts 'Preparing Geometries attributes...'

      locations = []
      csv.each do |row|
        if row['admin_level']
          locations << {
            name: row.fetch('name'),
            bounds: row.fetch('way'),
            # osm_id: row.fetch('abs').to_i.abs,
            osm_id: row.fetch('osm_id').to_i.abs,
            admin_level: row.fetch('admin_level'),
            country_code: ''
          }
        end
        if locations.length > 100
          Locations::Location.import(locations)
          locations = []
        end
      end
      Locations::Location.import(locations) unless locations.empty?
    end

    File.delete(TMP_PATH) if File.exist?(TMP_PATH)

    puts 'Locations updated...'
  end

  def self.load_name_data(url) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    LocationCsvSeeder.get_s3_file(url)
    keys = %i(name
              alternative_names
              osm_type
              osm_id
              class
              type
              coord
              place_rank
              importance
              street
              city
              county
              state
              country
              country_code
              display_name)

    Zlib::GzipReader.open(TMP_PATH) do |gz| # rubocop:disable Metrics/BlockLength
      # Zlib::GzipReader.open(DOWNLOADS_NAME_PATH) do |gz|
      csv = CSV.new(gz, headers: false)
      puts
      puts 'Preparing Location Names attributes...'
      names = []
      csv.each do |row|
        obj = {
          language: 'en'
        }
        # next unless %w(node relation).include?(row[keys.index(:osm_type)])
        keys.each_with_index do |k, i|
          if k == :coord
            obj[:point] = row[i]
          elsif k == :osm_id
            obj[k] = row[i].to_i.abs
            obj[:location_id] = Locations::Location.find_by_osm_id(obj[k])&.id
          elsif k == :type
            obj[:name_type] = row[i]
          elsif k == :class
            obj[:osm_class] = row[i]
          else
            obj[k] = row[i]
          end
        end

        names << obj
        if names.length > 100
          Locations::Name.import(names)
          names = []
        end
      end

      Locations::Name.import(names)
    end

    File.delete(TMP_PATH) if File.exist?(TMP_PATH)

    puts 'Location Names updated...'
  end

  def self.load_locode_data(url) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    # LocationCsvSeeder.get_s3_file(url)

    Zlib::GzipReader.open(url, encoding: Encoding::ISO_8859_1) do |gz|# rubocop:disable Metrics/BlockLength
      csv = CSV.new(gz, headers: false)
      puts
      puts 'Preparing Location Names (LOCODE) attributes...'
      names = []
      csv.each do |row|
        next if row[2].blank? || (row[0] == '=')

        obj = {
          language: 'en',
          country_code: row[1].downcase,
          locode: [row[1], row[2]].join,
          name: row[4]
        }

        if row[10].blank?
          name = Locations::Name.search(row[4]).results.first
          next if name.nil?

          point = name.point
        else
          location = lat_lng_from_string(row[10])
          point = RGeo::Geographic.spherical_factory(srid: 4326).point(location[:longitude], location[:latitude])
        end
        obj[:point] = point
        names << obj
        if names.length > 100
          Locations::Name.import(names)
          names = []
        end
      end

      Locations::Name.import(names)
    end

    File.delete(TMP_PATH) if File.exist?(TMP_PATH)

    puts 'Location Names updated...'
  end

  def germany_no_bounds
    puts 'Reading from csv...'

    LocationCsvSeeder.get_s3_file('data/germany_areas_no_data.csv.gz')

    Zlib::GzipReader.open(TMP_PATH) do |gz|
      csv = CSV.new(gz, headers: true)
      csv.each do |row|
        data = {
          city: row['ort'],
          country: 'Germany',
          postal_code: row['plz'],
          province: row['landkreis']
        }
        location = Locations::Location.find_by(country_code: 'de', name: row['plz'])
        if !location
          # binding.pry
        else
          location.update(data)
        end
      end
    end
    File.delete(TMP_PATH) if File.exist?(TMP_PATH)

    puts 'Germany Locations updated...'
  end

  def self.get_s3_file(key)
    s_3 = Aws::S3::Client.new

    file = s_3.get_object(
      bucket: 'assets.itsmycargo.com',
      key: key,
      response_content_disposition: 'application/x-gzip'
    ).body.read

    File.open(TMP_PATH, 'wb') { |f| f.write(file) }
  end

  def self.lat_lng_from_string(string)
    lat_string, lon_string = string.split
    latitude = BigDecimal(lat_string[0..1]) + (BigDecimal(lat_string[2..3]) / 60)
    latitude *= -1 if lat_string.ends_with?('S')
    longitude = BigDecimal(lon_string[0..2]) + (BigDecimal(lon_string[3..4]) / 60)
    longitude *= -1 if lon_string.ends_with?('W')

    { latitude: latitude, longitude: longitude }
  end
end
