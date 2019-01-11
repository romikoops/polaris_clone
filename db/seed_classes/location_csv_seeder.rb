# frozen_string_literal: true

require 'csv'

class LocationCsvSeeder
  TMP_PATH = 'tmp/tmp_csv.gz'
  def self.perform
    drydock_china
    
  end

  def self.drydock_china
    LocationCsvSeeder.get_s3_file('data/location_data/drydock_asia_china.csv.gz')

    Zlib::GzipReader.open(TMP_PATH) do |gz|
      csv = CSV.new(gz, headers: true)
      puts
      puts 'Preparing Geometries attributes...'
      data_rows = csv.readlines
      total = data_rows.size
      completion_percentage = 0
      new_completion_percentage = 0
      puts 'PROGRESS BAR'
      puts '_' * 100
      
      data_rows.each_with_index do |row, i|
        
        new_completion_percentage = i * 100 / total
        if new_completion_percentage > completion_percentage
          completion_percentage = new_completion_percentage
          print '-'
        end
        raw_data = row.entries
        location_attributes_by_lang = Hash.new {|h, k| h[k] = {}}
        bounds = raw_data.select {|arr| arr[0] == 'way'}&.first&.second
        next if bounds.nil?
        location_attributes = raw_data.reject{|arr| ['way', 'name', 'orig'].include?(arr[0])}
        .reject {|arr| arr[1].nil? }
        .map { |arr| [arr[0], JSON.parse(arr[1])] }
        .each { |attribute_array|
          attribute_array[1].each do |lang, text|
            next if text.nil?
            attribute_key = if attribute_array[0] == 'names'
              'name'
            else
              attribute_array[0]
            end

            location_attributes_by_lang[lang][attribute_key] = text
          end
        }
        location = Locations::Location.find_or_create_by!(bounds: bounds)
        begin
          location_attributes_by_lang.each do |lang, data|
            data['language'] = lang
            data['country'] = 'China'
            data['location_id'] = location.id

            name = Locations::Name.find_or_initialize_by(language: lang, location_id: location.id)
            name.update(data)
          end
        rescue => e
          binding.pry
        end
        
      end
    end
    File.delete(TMP_PATH) if File.exist?(TMP_PATH)

    puts 'Chinese Locations updated...'
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
