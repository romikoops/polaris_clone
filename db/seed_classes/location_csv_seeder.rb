# frozen_string_literal: true

require 'csv'

class LocationCsvSeeder
  TMP_PATH = 'tmp/tmp_csv.gz'
  DOWNLOADS_PATH = '/Users/warwickbeamish/Downloads/drydock_europe.csv.gz'
  def self.perform
    load_map_data('data/location_data/europe.csv.gz')
    load_name_data('data/location_data/germany_osm_1.csv.gz')
    # load_map_data('data/location_data/asia.csv.gz')
    # load_name_data('data/location_data/china_osm_2.csv.gz')
    # load_map_data('data/location_data/europe.csv.gz')
    # load_name_data('data/location_data/germany_osm_1.csv.gz')
    
  end

  def self.load_map_data(url)
    # LocationCsvSeeder.get_s3_file(url)

    Zlib::GzipReader.open(DOWNLOADS_PATH) do |gz|
      csv = CSV.new(gz, headers: true)
      puts
      puts 'Preparing Geometries attributes...'

      locations = []
      csv.each do |row|
        if row['admin_level']
          locations << {
            name: row['name'],
            bounds: row['way'],
            # osm_id: row['abs'].to_i.abs,
            osm_id: row['osm_id'].to_i.abs,
            admin_level: row['admin_level'],
            country_code: ''
          }
        end
        if locations.length > 100
          Locations::Location.import(locations)
          locations = []
        end
      end
      unless locations.empty?
        Locations::Location.import(locations)
      end
    end
    
    File.delete(TMP_PATH) if File.exist?(TMP_PATH)

    puts 'Locations updated...'
  end

  def self.load_name_data(url)
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

    Zlib::GzipReader.open(TMP_PATH) do |gz|
      csv = CSV.new(gz, headers: false)
      puts
      puts 'Preparing Location Names attributes...'
      names = []
      csv.each do |row|
        obj = {
          language: 'en'
        }
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

  def germany_no_bounds
    s3 = Aws::S3::Client.new
    bucket = 'assets.itsmycargo.com'
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
         location = Location.find_by(country: 'Germany', postal_code: row['plz'])
         if !location 
          raise "Location not found!"
         else
          location.update(data)
        end
      end
    end
    File.delete(TMP_PATH) if File.exist?(TMP_PATH)

    puts 'Germany Locations updated...'
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
