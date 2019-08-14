# frozen_string_literal: true

namespace :routing do
  task import_locations: :environment do
    TMP_PATH = 'tmp/tmp_csv.gz'
    s_3 = Aws::S3::Client.new
    puts 'Reading from csv...'

    file = s_3.get_object(
      bucket: 'assets.itsmycargo.com',
      key: 'data/location_data/locode_data.csv.gz',
      response_content_disposition: 'application/x-gzip'
    ).body.read

    File.open(TMP_PATH, 'wb') { |f| f.write(file) }
    locations = []
    Zlib::GzipReader.open(TMP_PATH) do |gz|
      csv = CSV.new(gz, headers: true)
      csv.each do |row|
        locations << {
          name: row['PLACE_NAME_WITHOUT_DIACRITICS'].gsub(' Pt', ''),
          locode: row['LOCODE'],
          country_code: row['country_code'],
          center: "POINT #{row['POINT'].delete(',')}",
          bounds: row['bounds']
        }
      end
    end

    Routing::Location.import(locations)
    File.delete(TMP_PATH) if File.exist?(TMP_PATH)

    hub_locations = []
    ::Legacy::Hub.find_each do |hub|
      next if Routing::Location.exists?(name: hub.nexus.name, country_code: hub.address.country.code.downcase)

      next if [hub.address.longitude, hub.address.latitude].any?(&:nil?)
      lng_lat = [hub.address.longitude, hub.address.latitude].join(' ')
      next unless lng_lat.present?

      hub_locations << {
        name: hub.nexus.name,
        locode: '',
        country_code: hub.address.country.code.downcase,
        center: "POINT (#{lng_lat})"
      }
    end

    Routing::Location.import(hub_locations)

    trucking_locations = []
    trucking_location_ids = Trucking::Location.where.not(location_id: nil).pluck(:location_id)
    Locations::Location.where(id: trucking_location_ids).where.not(bounds: nil).each do |location|
      trucking_locations << {
        name: location.name,
        country_code: location.country_code,
        center: location.bounds.centroid,
        bounds: location.bounds
      }
    end
    Routing::Location.import(trucking_locations)
  end
end
