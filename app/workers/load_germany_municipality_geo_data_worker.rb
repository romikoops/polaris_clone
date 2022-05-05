# frozen_string_literal: true

class LoadGermanyMunicipalityGeoDataWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  BUCKET = "itsmycargo-datahub"
  PATH = "production/maps/germany_administrative_municipality_boundaries.geojson"

  def perform
    municipalities_count = municipalities.count
    total municipalities_count
    municipalities.each_with_index do |municipality, index|
      name = municipality["properties"]["gen"]
      at index + 1, "name: #{name} #{index + 1}/#{municipalities_count}"
      bounds = RGeo::GeoJSON.decode(municipality["geometry"], geo_factory: RGeo::Geos.factory(srid: 4326))
      existing_location = Locations::Location.where(country_code: "de").find_by("name ILIKE ?", name)
      if existing_location
        existing_location.update(bounds: bounds, admin_level: 8)
      else
        Locations::Location.create(name: name, country_code: "de", bounds: bounds, admin_level: 8)
      end
    end
  end

  private

  def municipalities
    @municipalities ||= s3_data["features"]
  end

  def s3_data
    JSON.parse(s3.get_object(bucket: BUCKET, key: PATH)[:body].read)
  end

  def s3
    @s3 ||= Aws::S3::Client.new
  end
end
