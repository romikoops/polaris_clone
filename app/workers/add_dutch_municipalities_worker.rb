# frozen_string_literal: true

class AddDutchMunicipalitiesWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  BUCKET = "itsmycargo-datahub"
  PATHS = [
    "production/maps/netherlands_administrative_boundaries_level8_polygon.geojson",
    "production/maps/netherlands_administrative_boundaries_level10_polygon.geojson"
  ].freeze

  def perform
    PATHS.each do |path|
      geo_json = s3_data(path: path)
      geo_json["features"].each do |feature|
        name = feature.dig("properties", "name")
        admin_level = feature.dig("properties", "admin_level")
        bounds = RGeo::GeoJSON.decode(feature["geometry"], geo_factory: RGeo::Geos.factory(srid: 4326))

        existing_location = Locations::Location.find_by(country_code: "nl", name: name)
        if existing_location
          existing_location.update!(bounds: bounds, admin_level: admin_level)
        else
          Locations::Location.create!(name: name, country_code: "nl", bounds: bounds, admin_level: admin_level)
        end
      end
    end
  end

  private

  def s3_data(path:)
    JSON.parse(s3.get_object(bucket: BUCKET, key: path)[:body].read)
  end

  def s3
    @s3 ||= Aws::S3::Client.new
  end
end
