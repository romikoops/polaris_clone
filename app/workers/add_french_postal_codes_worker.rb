# frozen_string_literal: true

class AddFrenchPostalCodesWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  BUCKET = "itsmycargo-datahub"
  PATH = "production/maps/france_postal_code_boundaries_polygon.geojson"
  POINT_PATH = "production/maps/eu_postal_code_points.geojson"

  def perform
    postal_codes_count = postal_codes.count
    total postal_codes_count
    postal_codes.each_with_index do |postal_code, index|
      at index + 1, "#{index + 1}/#{postal_codes_count}"
      postal_bounds = RGeo::GeoJSON.decode(postal_code["geometry"], geo_factory: RGeo::Geos.factory(srid: 4326))
      postal_code_name = postal_code_name_from(bounds: postal_bounds)
      postal_code_name ||= Locations::Name.where("ST_Contains(?, ST_SetSRID(point, 4326))", postal_bounds).where.not(postal_code: nil).pluck(:postal_code).first
      postal_code_name ||= postal_code_from_address(point: postal_bounds.centroid)
      next if postal_code_name.blank? # There are about 1k postal codes with no name to be found

      existing_location = Locations::Location.find_by(country_code: "fr", name: postal_code_name)
      if existing_location
        existing_location.update!(bounds: postal_bounds, admin_level: nil)
      else
        Locations::Location.create!(name: postal_code_name, country_code: "fr", bounds: postal_bounds, admin_level: nil)
      end
    end
  end

  private

  def postal_code_from_address(point:)
    Legacy::Address.new(latitude: point.y, longitude: point.x).reverse_geocode.zip_code
  end

  def postal_codes
    @postal_codes ||= s3_data["features"]
  end

  def s3_data
    JSON.parse(s3.get_object(bucket: BUCKET, key: PATH)[:body].read)
  end

  def postal_code_name_from(bounds:)
    found_postal_code = french_postal_code_points.find do |postal_code_with_point|
      longitude, latitude = postal_code_with_point.dig("geometry", "coordinates")
      bounds.contains?(RGeo::Geos.factory(srid: 4326).point(longitude, latitude))
    end
    found_postal_code&.dig("properties", "POSTCODE")
  end

  def french_postal_code_points
    @french_postal_code_points ||= point_s3_data["features"].select { |geo_json| geo_json.dig("properties", "CNTR_ID") == "FR" }
  end

  def point_s3_data
    JSON.parse(s3.get_object(bucket: BUCKET, key: POINT_PATH)[:body].read)
  end

  def s3
    @s3 ||= Aws::S3::Client.new
  end
end
