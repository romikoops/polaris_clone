# frozen_string_literal: true

namespace :trucking do
  task netherlands: :environment do
    s3 = Aws::S3::Client.new
    geojson_string = s3.get_object(bucket: "assets.itsmycargo.com", key: "data/location_data/nl_4_digit_postal_areas.geojson").body.read
    geojsons = JSON.parse(geojson_string)
    location_count = 0
    name_count = 0
    names = []
    trucking_locations = []
    geojsons["features"].each do |feature|
      next if feature["geometry"].nil?

      postal_code = feature.dig("properties", "pc4")
      loc = Locations::Location.find_or_initialize_by(
        country_code: "nl", name: postal_code
      )
      loc.bounds = RGeo::GeoJSON.decode(feature).geometry
      next unless loc.save

      trucking_location = Trucking::Location.find_by(zipcode: postal_code, country_code: "NL")
      trucking_location.update(location: loc)
      trucking_locations << trucking_location
      location_count += 1
      names << {
        country: "Netherlands",
        country_code: "nl",
        name: postal_code,
        language: "en",
        postal_code: postal_code,
        location_id: loc.id,
        point: loc.bounds.centroid
      }
      name_count += 1
    end

    Locations::Name.import(names)
    Trucking::Trucking.where(location: trucking_locations)
      .where.not(hub_id: nil)
      .select(:load_type, :carriage, :hub_id, :truck_type)
      .distinct
      .each do |permutation|
      type_availability = Trucking::TypeAvailability.find_by(
        query_method: :location,
        load_type: permutation.load_type,
        carriage: permutation.carriage,
        truck_type: permutation.truck_type
      )
      Trucking::HubAvailability.find_or_create_by(
        hub_id: permutation.hub_id,
        type_availability: type_availability
      )
    end
    puts "FEATURE COUNT: #{geojsons["features"].size}"
    puts "LOCATION COUNT: #{location_count}"
    puts "NAME COUNT: #{name_count}"
  end
end
