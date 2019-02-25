# frozen_string_literal: true

require 'csv'

class LocationCsvSeeder
  TMP_PATH = 'tmp/tmp_csv.gz'
  # DOWNLOADS_PATH = '/Users/warwickbeamish/Downloads/loc182csv/netherlands_locodes.csv.gz'
  DOWNLOADS_PATH = '/Users/warwickbeamish/Downloads/drydock_asia_1.csv.gz'
  # DOWNLOADS_NAME_PATH = '/Users/warwickbeamish/Downloads/netherlands_osm_2.csv.gz'
  def self.perform
    # load_map_data('data/location_data/europe.csv.gz')
    # load_name_data('data/location_data/germany_osm_1.csv.gz')
    # load_map_data('data/location_data/asia.csv.gz')
    # load_name_data('data/location_data/china_osm_2.csv.gz')
    # load_map_data('data/location_data/europe.csv.gz')
    # load_name_data('data/location_data/netherlands_osm_2.csv.gz')
    # load_locode_data('/Users/warwickbeamish/Downloads/loc182csv/UNLOCODE_ListPart1.csv.gz')
    # load_locode_data('/Users/warwickbeamish/Downloads/loc182csv/UNLOCODE_ListPart2.csv.gz')
    # load_locode_data('/Users/warwickbeamish/Downloads/loc182csv/UNLOCODE_ListPart3.csv.gz')
    germany_no_bounds
  end

  def self.load_map_data(url)
    # LocationCsvSeeder.get_s3_file(url)

    Zlib::GzipReader.open(DOWNLOADS_PATH) do |gz|
      # binding.pry
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

  def self.load_locode_data(url)
    # LocationCsvSeeder.get_s3_file(url)
   
    Zlib::GzipReader.open(url, {encoding: Encoding::ISO_8859_1}) do |gz|
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
          point = RGeo::Geographic.spherical_factory(:srid => 4326).point(location[:longitude], location[:latitude])
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
    s3 = Aws::S3::Client.new

    file = s3.get_object(
      bucket: 'assets.itsmycargo.com',
      key: key,
      response_content_disposition: 'application/x-gzip'
    ).body.read

    File.open(TMP_PATH, 'wb') { |f| f.write(file) }
  end

  def self.lat_lng_from_string(string)
    lat_string, lon_string = string.split
    latitude = BigDecimal.new(lat_string[0..1]) + (BigDecimal.new(lat_string[2..3]) / 60)
    latitude *= -1 if lat_string.ends_with?('S')
    longitude = BigDecimal.new(lon_string[0..2]) + (BigDecimal.new(lon_string[3..4]) / 60)
    longitude *= -1 if lon_string.ends_with?('W')

    { latitude: latitude, longitude: longitude }
  end
end
