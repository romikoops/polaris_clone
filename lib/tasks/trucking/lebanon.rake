# frozen_string_literal: true

namespace :trucking do
  task lebanon: :environment do
    s3 = Aws::S3::Client.new
    geojson_string = s3.get_object(bucket: 'assets.itsmycargo.com', key: 'data/location_data/lebanon.geojson').body.read
    geojsons = JSON.parse(geojson_string)
    geojsons['features'].each do |feature|
      loc = Locations::Location.find_or_initialize_by(
        admin_level: 5, country_code: 'lb', name: feature.dig('properties', 'DISTRICT')
      )
      loc.bounds = RGeo::GeoJSON.decode(feature).geometry
      loc.save
    end
  end
end
