# frozen_string_literal: true

class SeedEuPostalCodesWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  BUCKET = "itsmycargo-datahub"
  PATH = "production/maps/eu_postal_code_points.geojson"
  POSTAL_CODE_KEYS = %w[postal_code country_id point].freeze

  def perform
    Trucking::PostalCode.import(complete_frame.to_a, { batch_size: 5000, on_duplicate_key_ignore: true })
  end

  private

  def postal_codes
    @postal_codes ||= s3_data["features"]
  end

  def s3_data
    @s3_data ||= JSON.parse(s3.get_object(bucket: BUCKET, key: PATH)[:body].read)
  end

  def complete_frame
    @complete_frame ||= postal_code_frame.inner_join(country_frame, on: { "country_code" => "country_code" })[POSTAL_CODE_KEYS]
  end

  def postal_code_frame
    @postal_code_frame ||= Rover::DataFrame.new(postal_code_frame_data)
  end

  def postal_code_frame_data
    @postal_code_frame_data ||= postal_codes.map do |postal_code|
      {
        "postal_code" => postal_code.dig("properties", "POSTCODE"),
        "country_code" => postal_code.dig("properties", "CNTR_ID"),
        "point" => RGeo::GeoJSON.decode(postal_code["geometry"], geo_factory: RGeo::Geos.factory(srid: 4326))
      }
    end
  end

  def country_frame
    @country_frame ||= Rover::DataFrame.new(Legacy::Country.select("id as country_id, code as country_code"))
  end

  def s3
    @s3 ||= Aws::S3::Client.new
  end
end
